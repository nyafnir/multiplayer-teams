require('prototypes.modules.utils.index')

require('prototypes.modules.economy.index')
teams = require('prototypes.modules.teams.index')

--- [Метод] init в обоих случаях: инициализация карты и загрузка/сохранение
local function start()
    --- Если это игровая компания, то не запускать мод
    if script.level.campaign_name then
        return false
    end

    return true
end

--- [Событие] Происходит после создания карты с включенным модом
script.on_init(function()
    if not start() then
        return
    end

    teams.init()
end)

--- [Событие] Происходит после загрузки и сохранения
script.on_load(function()
    -- И помните! "on_load() никогда не должен изменять `global`!"

    if not start() then
        return
    end
end)

--- [Событие] Игрок подключился
script.on_event(defines.events.on_player_joined_game, function(event)
    local player = game.players[event.player_index]
    logger('Игрок ' .. player.name .. ' присоединился к игре')

    initModuleEconomy(player)
end)
