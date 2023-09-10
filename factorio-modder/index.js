import { Command } from "commander";

import {
  closeGame,
  removeModArchives,
  createModArchive,
  updateModInListMods,
  waitGameClosed,
  startGameBySteam,
  getModInfo,
} from "./utils";

import packageJson from "./package.json" assert { type: "json" };

const { name } = packageJson;
const program = new Command();
const context = `[${name}]`;

program
  .name(`npm run ${name}`)
  .description("CLI для управления разрабатываемым модом")
  .version("3.0.0")

  .showHelpAfterError()
  .showSuggestionAfterError();

program
  .command("handle", { isDefault: true })

  .option("--src-dir [path]", "путь к папке с исходным кодом", "../src")
  .option(
    "--out-dir [path]",
    "путь к папке куда поместить архив",
    `${process.env.APPDATA}\\Factorio\\mods` // значение по умолчанию для Windows
  )

  .option("--remove-other-versions", "удалить другие версии мода", true)
  .option(
    "--update-list-mods",
    "обновить информацию о моде в списке модов игры",
    true
  )
  .option("--restart-game", "(пере)запустить игру по окончанию", true)

  .action(async (options) => {
    const {
      srcDir: pathToSrcDir,
      outDir: pathToOutDir,
      removeOtherVersions: needRemoveOtherVersions,
      updateListMods: needUpdateListMods,
      restartGame: needRestartGameWithMod,
    } = options;

    if (needRestartGameWithMod) {
      console.debug(`${context} Попытка закрыть игру ...`);

      await closeGame().catch((error) =>
        console.error(
          `${context} При закрытии произошла ошибка: ${JSON.stringify(error)}`
        )
      );
    }

    console.debug(
      `${context} Извлечение информации о моде из исходного кода ...`
    );
    const { name, version } = getModInfo(pathToSrcDir);

    if (needRemoveOtherVersions) {
      console.debug(`${context} Удаление других версий ...`);
      removeModArchives(pathToOutDir, name);
    }

    console.debug(`${context} Упаковка ...`);
    const pathToModArchive = createModArchive(
      pathToSrcDir,
      pathToOutDir,
      name,
      version
    );
    console.debug(`${context} Создан архив ${pathToModArchive}`);

    if (needUpdateListMods) {
      console.debug(`${context} Обновление списка модов ...`);
      updateModInListMods(pathToOutDir, name, true);
    }

    if (needRestartGameWithMod) {
      await waitGameClosed();

      console.debug(`${context} Запуск игры ...`);
      startGameBySteam();
    }
  });

program.parse();
