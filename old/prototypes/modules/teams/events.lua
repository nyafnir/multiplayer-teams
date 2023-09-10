local this = {
    onMTTeamInviteResolve = script.generate_event_name()
}

script.on_event(this.onMTTeamInviteResolve,
    ---@param event MTOfferEventResolve
    function(event)
        ---@type { teamName: string }
        local data = event.data

        local team = teamModule.service.getByName(data.teamName)

        ---Проверяем, что команда ещё существует
        if team == nil then
            return
        end

        local player = playerService.getById(event.playerId)
        local owner = playerService.getById(team.ownerId)

        if event.resolve then
            local status, result = pcall(teamModule.service.admin.changeTeamOfPlayer, team.title, player.name,
                nil)
            if status == false then
                player.print(result, team.color)
                owner.print(result, team.color)
                return
            end

            game.print({ configService.getKey('teams:invite.result-accept'), player.name, team.title }, team.color)
        else
            owner.force.print({ configService.getKey('teams:invite.result-cancel'), player.name, team.title }, team.color)
        end
    end)

return this