script.on_event(TEAM_RELATION_RESOLVE_EVENT_NAME,
    --- @param event OfferResolveDto
    function(event)
        local player = PlayerUtils.getById(event.playerId)
        --- @type RelationRequestDataDto
        local data = event.data

        local status, result = pcall(TeamModuleService.getByName, data.teamSourceName)
        if status == false then
            return LoggerService.chat(result, ColorUtils.colors.red, player)
        end
        local teamSource = result
        local forceSource = game.forces[teamSource.name]

        status, result = pcall(TeamModuleService.getByName, data.teamDestinationName)
        if status == false then
            return LoggerService.chat(result, ColorUtils.colors.red, player)
        end
        local teamDestination = result
        local forceDestionation = game.forces[teamDestination.name]

        if data.type == 'neutral' then
            if event.resolve then
                RelationModuleService.setNeutral(forceSource, forceDestionation)
                return LoggerService.chat({ 'mt.relations.set.neutral.result.yes', teamDestination.title,
                    teamSource.title })
            else
                LoggerService.chat({ 'mt.relations.set.neutral.result.no', teamDestination.title, teamSource.title }, nil,
                    forceSource)
                return LoggerService.chat(
                    { 'mt.relations.set.neutral.result.no', teamDestination.title, teamSource.title }, nil,
                    forceDestionation)
            end
        end

        if data.type == 'friend' then
            if event.resolve then
                RelationModuleService.setFriend(forceSource, forceDestionation)
                return LoggerService.chat({ 'mt.relations.set.friend.result.yes', teamDestination.title, teamSource
                    .title })
            else
                LoggerService.chat({ 'mt.relations.set.friend.result.no', teamDestination.title, teamSource.title }, nil,
                    forceSource)
                return LoggerService.chat(
                    { 'mt.relations.set.friend.result.no', teamDestination.title, teamSource.title }, nil,
                    forceDestionation)
            end
        end
    end)
