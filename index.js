const AdmZip = require("adm-zip");
const open = require('open');
const fs = require('fs');

require('dotenv').config()

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

    create(enable = true, openFactorio = true) {
        this.updateInfo()
        this.remove()
        this.createZipArchive()
        this.changeStatus(enable)
        openFactorio && this.goToFactorio()
    }

    updateInfo() {
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

        if (updateCount) {
            fs.writeFileSync(this.#pathToInfo, JSON.stringify(data, null, 2), 'utf8');
            console.info(`[${this.#context}] Информация о моде обновлена (${updateCount}).`);
        }
    }

    createZipArchive() {
        const modName = `${this.#package.name}_${this.#package.version}`
        const fileName = `${modName}.zip`;

        this.#zipService.addLocalFolder(this.#pathToSrc, modName);
        this.#zipService.writeZip(`${this.#pathToMods}\\${fileName}`);

        console.info(`[${this.#context}] Мод запакован в "${fileName}" и перемещён в папку игры.`);
    }

    remove() {
        let deletedCount = 0

        const regex = new RegExp(this.#package.name)
        fs.readdirSync(this.#pathToMods)
            .filter(fileName => regex.test(fileName))
            .map(fileName => deletedCount++ && fs.unlinkSync(`${this.#pathToMods}\\${fileName}`))

        if (deletedCount) {
            console.info(`[${this.#context}] Другие версии мода удалены (${deletedCount}).`);
        }
    }

    changeStatus(status = true) {
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

    goToFactorio() {
        console.info(`[${this.#context}] Запускаю игру...`);
        open('steam://rungameid/427520')
    }
}

new FactorioModBuilder({
    package: require('./package.json'),
    zipService: new AdmZip()
}).create(process.env.ENABLE ?? true, process.env.OPEN_GAME ?? true)
