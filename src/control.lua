--- Если это игровая компания, то не запускать мод
if script.level.campaign_name then
    return
end

--- [Инициализация модулей]

require('prototypes.modules.utils.index')

if getConfig('economy-enable') then
    require('prototypes.modules.economy.index')

    if getConfig('quests-enable') then
        require('prototypes.modules.quests.index')
    end
end

if getConfig('teams-enable') then
    require('prototypes.modules.teams.index')

    if getConfig('relations-enable') then
        require('prototypes.modules.relations.index')
    end
end

require('prototypes.modules.gui.index')

--- [Событие] Мод включён
script.on_init(function()
    --- [Команда] Смена расположения
    commands.add_command('mt-respawn', {'command-help.respawn'}, function(command)
        logger('Сделан вызов команды `respawn`')

        local player = game.players[command.player_index]

        if not player.admin then
            return game.print({'error-not-admin', game.players[command.player_index].name, command.name})
        end

        player.print('Команда ещё не реализована.')
    end)
end)

--- [Событие] Игрок подключился
script.on_event(defines.events.on_player_joined_game, function(event)
    local player = game.players[event.player_index]

    logger('Игрок ' .. player.name .. ' присоединился к игре')

    player.print({'multiplayer-teams.backstory'}, player.color)
end)
