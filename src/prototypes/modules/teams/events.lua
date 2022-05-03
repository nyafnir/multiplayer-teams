local events = {}

--- [Событие] Когда новый игрок присоединяется к игре
function events.onJoinNewPlayer(event)
    local player = getPlayerById(event.player_index)
    --- Устанавливаем стандартную команду, если игрок не в ней
    teams.model.changeTeamForPlayer(player, teams.store.getDefaultForce())
end

return events
