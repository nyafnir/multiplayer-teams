require('prototypes.modules.utils.index')

teams = require('prototypes.modules.teams.index')
spawns = require('prototypes.modules.spawns.index')
relations = require('prototypes.modules.relations.index') -- После `teams`
-- economy = require('prototypes.modules.economy.index') -- После `teams`

--- Последний, так как собирается из остальных модулей
local gui = require('prototypes.gui.index')

--- [Событие] Происходит после создания карты с включенным модом
script.on_init(function()
    if not game.is_multiplayer() then return end

    teams.on_init()
    spawns.on_init()
    relations.on_init()

    gui.on_init()
end)

--- [Событие] Происходит после загрузки и сохранения
script.on_load(function()
    --- И помните! "on_load() никогда не должен изменять `global`!"

    teams.on_load()
    spawns.on_load()
    relations.on_load()

    gui.on_load()
end)
