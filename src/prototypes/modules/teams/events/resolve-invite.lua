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
            LoggerService.chat({ 'mt.teams.invite.result.yes', player.name, team.title }, nil, owner.force)

            local status, result = pcall(TeamModuleService.changeTeamOfPlayerByAdmin, team.title, player.name, nil)
            if status == false then
                LoggerService.chat(result, nil, player)
                LoggerService.chat(result, nil, owner)
                return
            end

            LoggerService.chat({ 'mt.teams.create.backstory' }, team.color, player)
        else
            LoggerService.chat({ 'mt.teams.invite.result.no', player.name, team.title }, nil, owner.force)
        end
    end)
