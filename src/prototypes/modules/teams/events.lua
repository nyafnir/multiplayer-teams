local this = {}

--- [Событие] Когда новый игрок присоединяется к игре
function this.onJoinNewPlayer(event)
    local player = getPlayerById(event.player_index)
    --- Устанавливаем стандартную команду, если игрок не в ней
    teams.model.changeTeamForPlayer(player, teams.store.forces.getDefault())
end

return this
