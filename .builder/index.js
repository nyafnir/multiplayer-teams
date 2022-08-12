import AdmZip from "adm-zip";
import open from 'open';
import fs from 'fs';
import psList from 'ps-list';

class FactorioModBuilder {
    #context = 'Сборщик';

    #zipService = new AdmZip();

    #appData = process.env.APPDATA || (process.platform == 'darwin' ? process.env.HOME + '/Library/Preferences' : process.env.HOME + "/.local/share");
    #pathToMods = `${this.#appData}\\Factorio\\mods`;
    #pathToModListFile = `${this.#pathToMods}\\mod-list.json`;

    #src = '../';

    async _getFactorioPid() {
        const list = await psList();
        const factorio = list.find((process) => process.name === 'factorio.exe');
        return factorio?.pid;
    }

    async _closeFactorio() {
        const pid = await this._getFactorioPid()
        if (!pid) {
            return false;
        }

        console.info(`[${this.#context}] Игре отправлен сигнал к закрытию...`);
        try {
            process.kill(pid, 'SIGKILL');
        } catch (cause) {
            console.debug(`При закрытии получена ошибка: ${cause}`);
        }
        return true;
    }

    _updateInfo(pathToInfoFile = this.#src + 'info.json') {
        /**
         * @type {{
         * name: string;
         * version: string;
         * }}
         */
        const data = JSON.parse(fs.readFileSync(pathToInfoFile, 'utf8'));

        // Повышение счетчика количества сборок
        const versions = data.version.split('.');
        const countBuildings = versions.pop();
        versions.push(parseInt(countBuildings) + 1);
        data.version = versions.join('.');

        fs.writeFileSync(pathToInfoFile, JSON.stringify(data, null, 2), 'utf8');
        console.info(`[${this.#context}] Информация о моде обновлена.`);

        return data;
    }

    async _remove(modName, pathToMods = this.#pathToMods) {
        const files = await new Promise((resolve, reject) => {
            fs.readdir(this.#pathToMods, function (error, result) {
                if (error) {
                    reject(error);
                } else {
                    resolve(result);
                }
            });
        });

        const modFiles = files?.filter(fileName => new RegExp(`${modName}.*`).test(fileName));

        for (const fileName of modFiles) {
            await new Promise((resolve, reject) => {
                fs.unlink(`${pathToMods}\\${fileName}`, function (error, result) {
                    if (error) {
                        reject(error);
                    } else {
                        resolve(result);
                    }
                });
            });
        }

        modFiles?.length && console.info(`[${this.#context}] Найдены и удалены другие версии мода.`);
    }

    _createZipArchive(modName, version) {
        const fileName = `${modName}_${version}`
        const fileNameWithExt = `${fileName}.zip`;

        this.#zipService.addLocalFolder(this.#src + 'locale', fileName + '/' + 'locale');
        this.#zipService.addLocalFolder(this.#src + 'prototypes', fileName + '/' + 'prototypes');
        this.#zipService.addLocalFile(this.#src + 'changelog.txt', fileName + '/');
        this.#zipService.addLocalFile(this.#src + 'control.lua', fileName + '/');
        this.#zipService.addLocalFile(this.#src + 'data.lua', fileName + '/');
        this.#zipService.addLocalFile(this.#src + 'info.json', fileName + '/');
        this.#zipService.addLocalFile(this.#src + 'LICENSE', fileName + '/');
        this.#zipService.addLocalFile(this.#src + 'settings.lua', fileName + '/');
        this.#zipService.addLocalFile(this.#src + 'thumbnail.png', fileName + '/');

        this.#zipService.writeZip(`${this.#pathToMods}\\${fileNameWithExt}`);

        console.info(`[${this.#context}] Мод запакован в "${fileNameWithExt}" и перемещён в папку игры.`);
    }

    _changeStatus(modName, status = true, pathToModListFile = this.#pathToModListFile) {
        /**
         * @type {{ mods: { name: string; enabled: boolean; }[] }}
         */
        const data = JSON.parse(fs.readFileSync(pathToModListFile, 'utf8'));

        const mod = data.mods.find((mod) => mod.name === modName) || { name: modName };
        if (mod.enabled !== status) {
            mod.enabled = status

            fs.writeFileSync(pathToModListFile, JSON.stringify(data, null, 2), 'utf8');
            console.info(`[${this.#context}] Мод ${status ? 'активирован' : 'деактивирован'}!`);
        }
    }


    async _startFactorio(waitSeconds = 3) {
        const hasOpenFactorio = await this._getFactorioPid()
        if (hasOpenFactorio) {
            console.info(`[${this.#context}] При попытке запуска обнаружилось, что игра уже открыта, поэтому жду ${waitSeconds} сек...`);
            await new Promise(resolve => setTimeout(() => resolve(), waitSeconds * 1000));
            return await this._startFactorio();
        }

        console.info(`[${this.#context}] Запускаю игру...`);
        await open('steam://rungameid/427520');
    }

    async build() {
        await this._closeFactorio();
        const info = this._updateInfo();
        await this._remove(info.name);
        this._createZipArchive(info.name, info.version);
        this._changeStatus(info.name, true);
        await this._startFactorio();
    }
}

new FactorioModBuilder().build()
