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
            local status, result = pcall(TeamModuleService.changeTeamOfPlayerByAdmin, team.title, player.name, nil)
            if status == false then
                LoggerService.chat(result, team.color, player)
                LoggerService.chat(result, team.color, owner)
                return
            end

            LoggerService.chat({ ConfigService.getKey('teams:invite-result-accept'), player.name, team.title },
                team.color)
        else
            LoggerService.chat({ ConfigService.getKey('teams:invite-result-cancel'), player.name, team.title }, team
            .color, owner.force)
        end
    end)
