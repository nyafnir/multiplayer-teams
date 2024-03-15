script.on_event(TEAM_INVITE_RESOLVE_EVENT_NAME,
    --- @param event OfferResolveDto
    function(event)
        --- @type TeamInviteDataDto
        local data = event.data

        local player = PlayerUtils.getById(event.playerId)

        local status, result = pcall(TeamModuleService.getByName, data.teamName)
        if status == false then
            return LoggerService.chat(result, ColorUtils.colors.red, player)
        end
        local team = result

        local owner = PlayerUtils.getById(team.ownerId)

        if event.resolve then
            LoggerService.chat({ 'mt.teams.invite.result.yes', player.name, team.title }, nil, owner.force)

            status, result = pcall(TeamModuleService.changeTeamOfPlayerByAdmin, team.title, player.name, nil)
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
