local events = {}

--- [Событие] Когда новый игрок присоединяется к игре
function events.onJoinNewPlayer(event)
    local player = getPlayerById(event.player_index)
    --- Устанавливаем стандартную команду, если игрок не в ней
    teams.model.changeTeamForPlayer(player, teams.store.getDefaultForce())

    script.on_nth_tick(60 * 60 * tonumber(getConfig('teams:invite-timeout')), function(event)
        if #teams.store.invites.data == 0 then
            return
        end
    
        for _, data in pairs(teams.store.invites.data) do
            if data.date <= os.date() then
                data = nil
            end
        end
    end)
end

return events
