-- В этом файле доступен `script`

--- Если это игровая компания, то не запускать мод
if script.level.campaign_name then
    return
end

--- [Метод] Доступ к настройкам без префикса (только в этом файле)
local function config(name)
    return settings.startup['multiplayer-teams:' .. name].value
end

--- [Событие] Мод включён
script.on_init(function()
    commands.add_command('mt-respawn', {'command-help.respawn'}, function(command)
        local player = game.players[command.player_index]

        if not player.admin then 
            game.print({'error-not-admin', game.players[command.player_index].name, command.name})
            return
        end

        player.print('Команда ещё не реализована.')
    end)
end)

--- [Событие] Игрок подключился
script.on_event(defines.events.on_player_joined_game, function(event)
    local player = game.players[event.player_index]
    player.print({'multiplayer-teams.backstory'}, player.color)
end)

