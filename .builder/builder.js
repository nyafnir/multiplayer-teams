import AdmZip from "adm-zip";
import open from "open";
import { readdirSync, readFileSync, unlinkSync, writeFileSync } from "fs";
import psList from "ps-list";

import { sleep } from "./utils.js";

export class FactorioModBuilder {
  /** @private */
  zipService = new AdmZip();

  constructor() {
    const appData =
      process.env.APPDATA ||
      (process.platform == "darwin"
        ? process.env.HOME + "/Library/Preferences"
        : process.env.HOME + "/.local/share");

    this.pathToMods = `${appData}\\Factorio\\mods`;
    this.pathToModListFile = `${this.pathToMods}\\mod-list.json`;
    this.gameOpenLink = "steam://rungameid/427520";
    this.processName = "factorio.exe";
  }

  /**
   * @private
   * @param {string} message
   * @returns {Promise<string>}
   */
  formatLog(message) {
    return `[${this.constructor.name}] ${message}`;
  }

  /**
   * @private
   * @returns {Promise<string | undefined>}
   */
  async getGamePid() {
    const list = await psList();
    const game = list.find((process) => process.name === this.processName);
    return game?.pid;
  }

  /**
   * @public
   * @returns {Promise<void>}
   */
  async waitGameClosed(waitCloseGameSeconds) {
    const pid = await this.getGamePid();
    if (pid) {
      console.info(
        this.formatLog(
          `Игра открыта, жду её закрытия ${waitCloseGameSeconds} сек...`
        )
      );
      await sleep(waitCloseGameSeconds);
    }
  }

  /**
   * @public
   * @returns {Promise<void>}
   */
  async startGame() {
    console.info(this.formatLog(`Запускаю игру...`));
    await open(this.gameOpenLink);
  }

  /**
   * @public
   * @returns {Promise<void>}
   */
  async closeGame() {
    const pid = await this.getGamePid();
    if (!pid) {
      return;
    }

    console.info(this.formatLog(`Игре отправлен сигнал к закрытию...`));
    try {
      return process.kill(pid, "SIGKILL");
    } catch (error) {
      console.error(
        this.formatLog(
          `При закрытии произошла ошибка: ${JSON.stringify(error)}`
        )
      );
    }
  }

  /**
   * @public
   * @param {string} modName
   * @param {boolean} [removeInfo] Удалить информацию о моде из списка модов?
   * @returns {void}
   */
  removeModFromMods(modName, removeInfo = false) {
    const files = readdirSync(this.pathToMods);

    const modFiles = files?.filter((fileName) =>
      new RegExp(`${modName}.*`).test(fileName)
    );
    if (!modFiles?.length) {
      return;
    }

    modFiles.map((fileName) => {
      unlinkSync(`${this.pathToMods}\\${fileName}`);
      console.info(
        this.formatLog(`Найдена и удалена старая версия "${fileName}".`)
      );
    });

    if (removeInfo) {
      /**
       * @type {{ mods: { name: string; enabled: boolean; }[] }}
       */
      const data = JSON.parse(readFileSync(this.pathToModListFile, "utf8"));
      const modIndex = data.mods.findIndex((mod) => mod.name === modName);
      if (modIndex !== -1) {
        delete data.mods[modIndex];
        writeFileSync(pathToModListFile, JSON.stringify(data, null, 2), "utf8");
      }
    }
  }

  /**
   * @public
   * @param {string} pathToModFiles
   * @returns {{ name: string; version: string }}
   */
  getModInfo(pathToModFiles) {
    return JSON.parse(readFileSync(`${pathToModFiles}/info.json`, "utf8"));
  }

  /**
   * @public
   * @param {string} pathToModFiles
   * @param {boolean} copyToMods
   * @returns {void}
   */
  createModInMods(pathToModFiles, modName, version) {
    const fileName = `${modName}_${version}`;
    const fileNameWithExt = `${fileName}.zip`;

    const dirNames = ["locale", "prototypes"];
    for (const dirName of dirNames) {
      this.zipService.addLocalFolder(
        pathToModFiles + dirName,
        fileName + "/" + dirName
      );
    }

    const fileNames = [
      "LICENSE",
      "info.json",
      "thumbnail.png",
      "changelog.txt",
      "settings.lua",
      "control.lua",
      "data.lua",
    ];
    for (const fileName of fileNames) {
      this.zipService.addLocalFile(pathToModFiles + fileName, fileName + "/");
    }

    this.zipService.writeZip(`${this.pathToMods}\\${fileNameWithExt}`);

    console.info(
      this.formatLog(`Новая версия "${fileNameWithExt}" помещена в папку игры.`)
    );

    this.activateModInMods(modName);
  }

  /**
   * @private
   */
  activateModInMods(modName) {
    /**
     * @type {{ mods: { name: string; enabled: boolean; }[] }}
     */
    const data = JSON.parse(readFileSync(this.pathToModListFile, "utf8"));

    let mod = data.mods.find((mod) => mod.name === modName);
    if (!mod) {
      mod = {
        name: modName,
        enabled: true,
      };
    } else if (!mod.enabled) {
      mod.enabled = true;
    } else {
      return;
    }

    writeFileSync(
      this.pathToModListFile,
      JSON.stringify(data, null, 2),
      "utf8"
    );

    console.info(this.formatLog(`Мод активирован!`));
  }
}
