require('prototypes.modules.utils.index')
require('prototypes.modules.economy.index')
teams = require('prototypes.modules.teams.index')
relations = require('prototypes.modules.relations.index') -- Строго после `teams`
spawns = require('prototypes.modules.spawns.index')
local gui = require('prototypes.gui.index')

--- init в обоих случаях: инициализация карты и загрузка/сохранение
local function start()
    --- Если это игровая компания, то не запускать мод
    if script.level.campaign_name ~= nil then
        return false
    end

    teams.start()
    relations.start()
    spawns.start()
    gui.start()

    return true
end

--- [Событие] Происходит после создания карты с включенным модом
script.on_init(function()
    if not start() then
        return
    end
end)

--- [Событие] Происходит после загрузки и сохранения
script.on_load(function()
    -- И помните! "on_load() никогда не должен изменять `global`!"

    if not start() then
        return
    end
end)

-- TODO: move to module: `economy.start()`
script.on_event(defines.events.on_player_joined_game, function(event)
    local player = getPlayerById(event.player_index)
    logger('Игрок ' .. player.name .. ' присоединился к игре')
    initModuleEconomy(player)
end)
