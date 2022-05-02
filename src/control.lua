require('prototypes.modules.utils.index')

require('prototypes.modules.economy.index')
require('prototypes.modules.quests.index')
require('prototypes.modules.teams.index')
require('prototypes.modules.relations.index')
require('prototypes.modules.gui.index')

--- [Method] Init in both cases: map initialization and loading/saving
local function start()
    --- Если это игровая компания, то не запускать мод
    if script.level.campaign_name then
        return false
    end

    return true
end

--- [Event] Executed after creating a map with the mod enabled
script.on_init(function()
    if not start() then
        return
    end
end)

--- [Event] Executed after loading and saving
script.on_load(function()
    -- И помните! "on_load() никогда не должен изменять `global`!"

    if not start() then
        return
    end
end)

--- [Event] Player connected
script.on_event(defines.events.on_player_joined_game, function(event)
    local player = game.players[event.player_index]
    logger('Игрок ' .. player.name .. ' присоединился к игре')
    initModuleEconomy(player)

    player.print({'multiplayer-teams.backstory'}, player.color)
end)
