local this = {}

--- [Событие] Когда новый игрок присоединяется к игре
function this.onJoinNewPlayer(event)
    local player = getPlayerById(event.player_index)
    --- Устанавливаем стандартную команду, если игрок не в ней
    teams.base.change(player, teams.store.forces.getDefault())
end

function this.onRemovingForce(event)
    --- удаляем приглашения в эту команду
    teams.store.invites.removeByForceName(event.source.name)
end

return this
