--- Сервис управления отношениями между командами и внутри них.
--- Суть работы в том что меняет отношения через методы внутри force.
RelationModuleService = {}

--- @public
--- Переключение режима "прекращения огня" внутри своей команды
--- @param requesterId number
function RelationModuleService.switchFriendlyFire(requesterId)
    local requester = PlayerUtils.getById(requesterId)

    local team = TeamModuleService.getByName(requester.force.name)

    --- Проверка, что это владелец команды
    if team.ownerId ~= requester.index then
        error({ 'mt.teams.errors.team-not-owner' })
    end

    if requester.force.friendly_fire then
        requester.force.friendly_fire = false
        LoggerService.chat({ 'mt.relations.friendly-fire.result.no', team.title },
            nil, requester.force)
    else
        requester.force.friendly_fire = true
        LoggerService.chat({ 'mt.relations.friendly-fire.result.yes', team.title },
            nil, requester.force)
    end
end

--- @private
--- Установить враждебные отношения
--- @param forceSource ForceIdentification
--- @param forceDestionation ForceIdentification
function RelationModuleService.setEnemy(forceSource, forceDestionation)
    -- обозначаем вражду
    forceSource.set_friend(forceDestionation, false)
    forceDestionation.set_friend(forceSource, false)
    -- "прекращения огня" - разрешаем стрелять по друг другу
    forceSource.set_cease_fire(forceDestionation, false)
    forceDestionation.set_cease_fire(forceSource, false)
end

--- @private
--- Установить нейтральные отношения
--- @param forceSource ForceIdentification
--- @param forceDestionation ForceIdentification
function RelationModuleService.setNeutral(forceSource, forceDestionation)
    -- обозначаем вражду
    forceSource.set_friend(forceDestionation, false)
    forceDestionation.set_friend(forceSource, false)
    -- "прекращения огня" - не разрешаем стрелять по друг другу
    forceSource.set_cease_fire(forceDestionation, true)
    forceDestionation.set_cease_fire(forceSource, true)
end

--- @private
--- Установить дружественные отношения
--- @param forceSource ForceIdentification
--- @param forceDestionation ForceIdentification
function RelationModuleService.setFriend(forceSource, forceDestionation)
    -- обозначаем дружбу
    forceSource.set_friend(forceDestionation, true)
    forceDestionation.set_friend(forceSource, true)
    -- "прекращения огня" - не разрешаем стрелять по друг другу
    forceSource.set_cease_fire(forceDestionation, true)
    forceDestionation.set_cease_fire(forceSource, true)
end

--- @public
--- Запрос на изменение отношений с указанной командой
--- @param teamDestinationTitle string | nil
--- @param type 'enemy' | 'friend' | 'neutral'
--- @param requesterId number
function RelationModuleService.setRelation(teamDestinationTitle, type, requesterId)
    local requester = PlayerUtils.getById(requesterId)

    local teamSource = TeamModuleService.getByName(requester.force.name)
    local forceSource = requester.force

    if teamSource.ownerId ~= requester.index then
        error({ 'mt.teams.errors.team-not-owner' })
    end

    if teamDestinationTitle == nil then
        error({ 'mt.teams.errors.team-title-required' })
    end

    local teamDestination = TeamModuleService.getByTitle(teamDestinationTitle)
    local forceDestionation = game.forces[teamDestination.name]

    if teamSource.id == teamDestination.id then
        error({ 'mt.relations.errors.cant-offer-self-team' })
    end

    if teamDestination.ownerId == nil then
        error({ 'mt.relations.errors.cant-offer-default-team' })
    end

    if type == 'enemy' then
        --- Если нейтральная, то будет true как и у друзей, поэтому
        --- тут проверяется только вражда
        if forceSource.is_friend(forceDestionation) == false then
            error({ 'mt.relations.errors.already-has-the-relation', teamDestination.title })
        end

        RelationModuleService.setEnemy(forceSource, forceDestionation)

        return LoggerService.chat({ 'mt.relations.set.enemy.result', teamSource.title, teamDestination.title })
    end

    --- @type number
    local timeoutMinutes = ConfigService.getValue('relations:request:timeout')

    if type == 'neutral' then
        if forceSource.is_friend(forceDestionation) and forceSource.get_friend(forceDestionation) == false then
            error({ 'mt.relations.errors.already-has-the-relation', teamDestination.title })
        end

        --- Понижение отношений без заявки
        if forceSource.get_friend(forceDestionation) then
            RelationModuleService.setNeutral(forceSource, forceDestionation)
            return LoggerService.chat(
                {
                    'mt.relations.set.neutral.result.friend-become-neutral',
                    teamSource.title,
                    teamDestination.title
                }
            )
        end

        OfferModuleService.create({
            eventId = TEAM_RELATION_RESOLVE_EVENT_NAME,
            playerId = teamDestination.ownerId,
            localisedMessage = { 'mt.relations.set.neutral.result.incoming', teamSource.title },
            timeoutMinutes = timeoutMinutes,
            data = {
                teamSourceName = teamSource.name,
                teamDestinationName = teamDestination.name,
                type = type
            }
        }, true)

        return LoggerService.chat(
            {
                'mt.relations.set.neutral.result.outcoming',
                teamSource.title,
                TimeUtils.minutesToClock(timeoutMinutes)
            },
            nil,
            requester.force
        )
    end

    if type == 'friend' then
        if forceSource.get_friend(forceDestionation) then
            error({ 'mt.relations.errors.already-has-the-relation', teamDestination.title })
        end

        OfferModuleService.create({
            eventId = TEAM_RELATION_RESOLVE_EVENT_NAME,
            playerId = teamDestination.ownerId,
            localisedMessage = { 'mt.relations.set.friend.result.incoming', teamSource.title },
            timeoutMinutes = timeoutMinutes,
            data = {
                teamSourceName = teamSource.name,
                teamDestinationName = teamDestination.name,
                type = type
            }
        }, true)

        return LoggerService.chat(
            {
                'mt.relations.set.friend.result.outcoming',
                teamSource.title,
                TimeUtils.minutesToClock(timeoutMinutes)
            },
            nil,
            requester.force
        )
    end
end

--- @public
--- Возвращает список команд сгруппированных по отношениям к переданной команде
--- @param teamName string
--- @return { friends: table<TeamEntity>, enemies: table<TeamEntity>, neutrals: table<TeamEntity> }
function RelationModuleService.getAllFor(teamName)
    local forceSource = game.forces[teamName]

    local result = {
        friends = {},
        enemies = {},
        neutrals = {}
    }

    for _, team in pairs(TeamModuleService.getAll()) do
        if team.name == teamName
            or team.name == 'player'
            or team.name == 'neutral'
            or team.name == 'enemy'
        then
            goto continue
        end

        if forceSource.get_friend(team.name) then
            table.insert(result.friends, team)
            goto continue
        end

        if forceSource.is_friend(team.name) then
            table.insert(result.neutrals, team)
        else
            table.insert(result.enemies, team)
        end

        ::continue::
    end

    return result
end
