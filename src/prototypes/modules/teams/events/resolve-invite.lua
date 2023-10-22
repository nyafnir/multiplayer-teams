script.on_event(TEAM_INVITE_RESOLVE_EVENT_NAME,
    --- @param event OfferResolveDto
    function(event)
        --- @type TeamInviteDataDto
        local data = event.data
        local team = TeamModuleService.getByName(data.teamName)

        --- Проверяем, что команда ещё существует
        if team == nil then
            return
        end

        local player = PlayerUtils.getById(event.playerId)
        local owner = PlayerUtils.getById(team.ownerId)

        if event.resolve then
            -- local status, result = pcall(teamModule.service.admin.changeTeamOfPlayer, team.title, player.name,
            --     nil)
            -- if status == false then
            --     player.print(result, team.color)
            --     owner.print(result, team.color)
            --     return
            -- end

            -- game.print({ configService.getKey('teams:invite.result-accept'), player.name, team.title }, team.color)
        else
            -- owner.force.print({ configService.getKey('teams:invite.result-cancel'), player.name, team.title }, team.color)
        end
    end)
