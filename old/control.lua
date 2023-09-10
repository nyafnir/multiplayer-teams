---@diagnostic disable: lowercase-global

---Импорты используемые по проекту
---Порядок зависит от использования одного модуля другим

require('prototypes.utils.index')
require('prototypes.services.index')

offerModule = require('prototypes.modules.offers.module')
spawnModule = require('prototypes.modules.spawns.module')
teamModule = require('prototypes.modules.teams.module') -- Использует `spawnModule`, `offerModule`
relationModule = require('prototypes.modules.relations.module') -- Использует `teamModule`, `offerModule`
-- economyModule = require('prototypes.modules.economy.module') -- Использует `teamModule`
questModule = require('prototypes.modules.quests.module') -- Использует `economyModule`
guiModule = require('prototypes.modules.gui.module') -- Последний, так как собирается из остальных модулей

--- [Событие] Происходит после создания карты с включенным модом
script.on_init(function()
    offerModule.on_init()
    teamModule.on_init()
    -- economyModule.on_init()
    relationModule.on_init()
    spawnModule.on_init()
    questModule.on_init()
    guiModule.on_init()
end)

--- [Событие] Происходит после загрузки и сохранения
--- "on_load() никогда не должен изменять `global`!"
script.on_load(function()
    offerModule.on_load()
    teamModule.on_load()
    -- economyModule.on_load()
    relationModule.on_load()
    spawnModule.on_load()
    questModule.on_load()
    guiModule.on_load()
end)
