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

    async _closeFactorio() {
        const list = await psList();

        const factorio = list.find((process) => process.name === 'factorio.exe');
        if (factorio) {
            console.info(`[${context}] Игре отправлен сигнал к закрытию...`);
            process.kill(factorio.pid, 'SIGKILL');
            return true;
        }

        return false;
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
        const fileName = `${modName}_${version}.zip`;

        this.#zipService.addLocalFolder(this.#src + 'locale');
        this.#zipService.addLocalFolder(this.#src + 'prototypes');
        this.#zipService.addLocalFile(this.#src + 'changelog.txt');
        this.#zipService.addLocalFile(this.#src + 'control.lua');
        this.#zipService.addLocalFile(this.#src + 'data.lua');
        this.#zipService.addLocalFile(this.#src + 'info.json');
        this.#zipService.addLocalFile(this.#src + 'LICENSE');
        this.#zipService.addLocalFile(this.#src + 'settings.lua');
        this.#zipService.addLocalFile(this.#src + 'thumbnail.png');

        this.#zipService.writeZip(`${this.#pathToMods}\\${fileName}`);

        console.info(`[${this.#context}] Мод запакован в "${fileName}" и перемещён в папку игры.`);
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

    async _startFactorio() {
        const result = await this._closeFactorio();
        if (result) {
            console.info(`[${this.#context}] При попытке запуска обнаружилось, что игра уже открыта, поэтому повторно отправляю сигнал закрытия через секунду...`);
            await new Promise(resolve => setTimeout(() => resolve(), 1000));
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
        this._changeStatus(info.name, modStatus);
        await this._startFactorio();
    }
}

new FactorioModBuilder().build()
