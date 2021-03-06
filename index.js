import AdmZip from "adm-zip";
import open from 'open';
import fs from 'fs';
import psList from 'ps-list';
import dotenv from 'dotenv'
import packageJson from './package.json'

dotenv.config()

/**
* @typedef {import('./package.json')} Package 
*/

class FactorioModBuilder {
    #context = 'Сборщик'

    #appData = process.env.APPDATA || (process.platform == 'darwin' ? process.env.HOME + '/Library/Preferences' : process.env.HOME + "/.local/share")

    #pathToSrc = './src'
    #pathToInfo = `${this.#pathToSrc}/info.json`

    #pathToMods = `${this.#appData}\\Factorio\\mods`
    #pathToModList = `${this.#pathToMods}\\mod-list.json`

    #steamLinkToRunFactorio = 'steam://rungameid/427520'
    #factorioProcessName = 'factorio.exe'

    /** @type {Package} */
    #package

    /** @type {AdmZip} */
    #zipService

    /**
     * @param {{
     * package: Package, 
     * zipService: AdmZip
     * }} options
     */
    constructor(options) {
        this.#package = options.package
        this.#package.name = this.#package.name
            ?.split('-')
            ?.map((str) => str[0].toUpperCase() + str.slice(1))
            ?.join('')
        this.#zipService = options.zipService
    }

    async create(modStatus = true, openFactorio = true) {
        openFactorio && await this._closeFactorio()

        setTimeout(async () => {
            this._updateInfo()
            await this._remove()
            this._createZipArchive()
            this._changeStatus(modStatus)

            openFactorio && this._startFactorio()
        },
            openFactorio ? (parseInt(process.env.REOPEN_WAIT_SECONDS) || 3) * 1000 : 0
        )
    }

    _updateLicense() {
        const outsidePath = 'LICENSE'
        const insidePath = `${this.#pathToSrc}/LICENSE`

        if (!fs.existsSync(outsidePath) || !fs.existsSync(insidePath)) {
            return false
        }

        const outsideBuffer = fs.readFileSync(outsidePath)
        const insideBuffer = fs.readFileSync(insidePath)

        if (outsideBuffer.compare(insideBuffer) !== 0) {
            fs.copyFileSync(outsidePath, insidePath);
            return true
        }

        return false
    }

    _updateInfo() {
        const data = JSON.parse(fs.readFileSync(this.#pathToInfo, 'utf8'));

        let updateCount = 0

        if (data.name !== this.#package.name) {
            data.name = this.#package.name
            updateCount++
        }

        if (data.version !== this.#package.version) {
            data.version = this.#package.version
            updateCount++
        }

        const author = [this.#package.author, ...(this.#package.contributors || [])].join(' & ')
        if (data.author !== author) {
            data.author = author
            updateCount++
        }

        if (data.title !== this.#package.title) {
            data.title = this.#package.title
            updateCount++
        }

        if (data.description !== this.#package.description) {
            data.description = this.#package.description
            updateCount++
        }

        if (data.contact !== this.#package.contact) {
            data.contact = this.#package.contact
            updateCount++
        }

        if (data.homepage !== this.#package.homepage) {
            data.homepage = this.#package.homepage
            updateCount++
        }

        const haveUpdateLicense = this._updateLicense()
        haveUpdateLicense && updateCount++

        if (updateCount) {
            fs.writeFileSync(this.#pathToInfo, JSON.stringify(data, null, 2), 'utf8');
            console.info(`[${this.#context}] Информация о моде обновлена (${updateCount}).`);
        }
    }

    _createZipArchive() {
        const modName = `${this.#package.name}_${this.#package.version}`
        const fileName = `${modName}.zip`;

        this.#zipService.addLocalFolder(this.#pathToSrc, modName);
        this.#zipService.writeZip(`${this.#pathToMods}\\${fileName}`);

        console.info(`[${this.#context}] Мод запакован в "${fileName}" и перемещён в папку игры.`);
    }

    async _remove() {
        let deletedCount = 0

        const files = await new Promise((resolve, reject) => {
            fs.readdir(this.#pathToMods, function (error, result) {
                if (error) {
                    reject(error);
                } else {
                    resolve(result);
                }
            });
        });

        const regex = new RegExp(this.#package.name)
        const modFiles = files?.filter(fileName => regex.test(fileName))

        for (const fileName of modFiles) {
            deletedCount++
            await new Promise((resolve, reject) => {
                fs.unlink(`${this.#pathToMods}\\${fileName}`, function (error, result) {
                    if (error) {
                        reject(error);
                    } else {
                        resolve(result);
                    }
                });
            });
        }

        if (deletedCount) {
            console.info(`[${this.#context}] Другие версии мода удалены (${deletedCount}).`);
        }
    }

    _changeStatus(status = true) {
        /**
         * @type {{ mods: { name: string, enabled: boolean }[] }}
         */
        const data = JSON.parse(fs.readFileSync(this.#pathToModList, 'utf8'));

        const mod = data.mods.find((mod) => mod.name === this.#package.name) || { name: this.#package.name }
        if (mod.enabled !== status) {
            mod.enabled = status
            fs.writeFileSync(this.#pathToModList, JSON.stringify(data, null, 2), 'utf8');
            console.info(`[${this.#context}] Мод ${status ? 'активирован' : 'деактивирован'}!`);
        }
    }

    async _closeFactorio() {
        const list = await psList()

        const factorio = list.find((p) => p.name === this.#factorioProcessName)
        if (factorio) {
            console.info(`[${this.#context}] Закрываю игру...`);
            process.kill(factorio.pid, 'SIGKILL')
            return true
        }

        return false
    }

    async _startFactorio() {
        console.info(`[${this.#context}] Запускаю игру...`);
        await open(this.#steamLinkToRunFactorio)
    }
}

new FactorioModBuilder({
    package: packageJson,
    zipService: new AdmZip()
}).create(process.env.ACTIVATE_MOD === 'true', process.env.OPEN_GAME === 'true')
