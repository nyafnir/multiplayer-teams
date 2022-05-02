local events = {}

--- [Событие] Когда новый игрок присоединяется к игре
function events:onJoinNewPlayer(event)
    local player = game.players[event.player_index]
    --- Устанавливаем стандартную команду, если игрок не в ней
    teams.model.changeTeamForPlayer(player, teams.store.getDefault())
end

return events
