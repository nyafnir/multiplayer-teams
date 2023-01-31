local this = {}

---@param teamName string
---@return table
function this.listFor(teamName)
    local requesterForce = game.forces[teamName]

    local result = {
        friends = {},
        enemies = {},
        neutrals = {}
    }

    ---@param otherTeamName string
    ---@param team MTTeam
    for otherTeamName, team in pairs(teamModule.service.getTeams()) do
        if otherTeamName == teamName
            or otherTeamName == 'player'
            or otherTeamName == 'neutral'
            or otherTeamName == 'enemy'
        then
            goto continue
        end

        local teamTitle = team.title

        if requesterForce.get_friend(otherTeamName) then
            table.insert(result.friends, teamTitle)
            goto continue
        end

        if requesterForce.is_enemy(otherTeamName) then
            table.insert(result.enemies, teamTitle)
        else
            table.insert(result.neutrals, teamTitle)
        end

        ::continue::
    end

    return result
end

---@param otherTeamTitle string | nil
---@param requesterId number
function this.setEnemy(otherTeamTitle, requesterId)
    local requester = playerService.getById(requesterId)

    ---@type MTTeam Здесь никогда не будет `nil`
    ---@diagnostic disable-next-line: assign-type-mismatch
    local team = teamModule.service.getByName(requester.force.name)

    if team.ownerId ~= requester.index then
        error({ configService.getKey('relations:set.error-team-not-owner') })
    end

    if otherTeamTitle == nil or otherTeamTitle == '' then
        error({ configService.getKey('relations:set.error-title-not-specified') })
    end
    local otherTeam = teamModule.service.getByTitle(otherTeamTitle)
    if otherTeam == nil then
        error({ configService.getKey('relations:set.error-team-not-founded'), otherTeam })
    end
    local enemyForce = game.forces[otherTeam.name]

    if team.id == otherTeam.id then
        error({ configService.getKey('relations:set.error-cant-offer-self'), otherTeam })
    end

    ---Если нейтральная, то будет true как и у друзей, поэтому
    ---тут проверяется только вражда
    if requester.force.is_friend(enemyForce) == false then
        error({ configService.getKey('relations:set:enemy.error-already-enemy'), otherTeam })
    end

    requester.force.set_friend(enemyForce, false)
    requester.force.set_cease_fire(enemyForce, true)

    game.print({ configService.getKey('trelations:set:enemy.result'), team.title, otherTeam.title },
        colorService.list.yellow)
end

---@param otherTeamTitle string | nil
---@param requesterId number
function this.setFriend(otherTeamTitle, requesterId)
    local requester = playerService.getById(requesterId)

    ---@type MTTeam Здесь никогда не будет `nil`
    ---@diagnostic disable-next-line: assign-type-mismatch
    local team = teamModule.service.getByName(requester.force.name)

    if team.ownerId ~= requester.index then
        error({ configService.getKey('relations:set.error-team-not-owner') })
    end

    if otherTeamTitle == nil or otherTeamTitle == '' then
        error({ configService.getKey('relations:set.error-title-not-specified') })
    end
    local otherTeam = teamModule.service.getByTitle(otherTeamTitle)
    if otherTeam == nil then
        error({ configService.getKey('relations:set.error-team-not-founded'), otherTeam })
    end
    local friendForce = game.forces[otherTeam.name]

    if team.id == otherTeam.id then
        error({ configService.getKey('relations:set.error-cant-offer-self'), otherTeam })
    end

    if requester.force.get_friend(friendForce) then
        error({ configService.getKey('relations:set:friend.error-already-friend'), otherTeam })
    end

    ---@type MTOfferInput
    local offerInput = {
        eventName = 'relation_offer',
        playerId = otherTeam.ownerId,
        localisedMessage = { configService.getKey('relations:set:friend.result-recipient'), team.title },
        timeoutMinutes = configService.get('relations:offer-timeout'),
        data = {
            teamName = team.name,
            type = 'friend'
        }
    }

    offerModule.service.create(offerInput)

    requester.force.print({ configService.getKey('relations:set:friend.result-sender'), otherTeam.title,
        Utils.time.minutesToClock(offerInput.timeoutMinutes) },
        team.color)
end

---@param otherTeamTitle string | nil
---@param requesterId number
function this.setNeutral(otherTeamTitle, requesterId)
    local requester = playerService.getById(requesterId)

    ---@type MTTeam Здесь никогда не будет `nil`
    ---@diagnostic disable-next-line: assign-type-mismatch
    local team = teamModule.service.getByName(requester.force.name)

    if team.ownerId ~= requester.index then
        error({ configService.getKey('relations:set.error-team-not-owner') })
    end

    if otherTeamTitle == nil or otherTeamTitle == '' then
        error({ configService.getKey('relations:set.error-title-not-specified') })
    end
    local otherTeam = teamModule.service.getByTitle(otherTeamTitle)
    if otherTeam == nil then
        error({ configService.getKey('relations:set.error-team-not-founded'), otherTeam })
    end
    local neutralForce = game.forces[otherTeam.name]

    if team.id == otherTeam.id then
        error({ configService.getKey('relations:set.error-cant-offer-self'), otherTeam })
    end

    if requester.force.is_friend(neutralForce) == true
        and requester.force.get_friend(neutralForce) == false
    then
        error({ configService.getKey('relations:set:neutral.error-already-neutral'), otherTeam })
    end

    ---Если друзья, то без заявок
    if requester.force.get_friend(neutralForce) then
        requester.force.set_friend(neutralForce, false)
        requester.force.set_cease_fire(neutralForce, false)

        return game.print({ configService.getKey('relations:set:neutral.become-neutral'), team.title, otherTeam.title },
            team.color)
    end

    ---@type MTOfferInput
    local offerInput = {
        eventName = 'relation_offer',
        playerId = otherTeam.ownerId,
        localisedMessage = { configService.getKey('relations:set:neutral.result-recipient'), team.title },
        timeoutMinutes = configService.get('relations:offer-timeout'),
        data = {
            teamName = team.name,
            type = 'neutral'
        }
    }

    offerModule.service.create(offerInput)

    requester.force.print({ configService.getKey('relations:set:neutral.result-sender'), otherTeam.title,
        Utils.time.minutesToClock(offerInput.timeoutMinutes) },
        team.color)
end

---@param requesterId number
function this.switchFriendlyFire(requesterId)
    local requester = playerService.getById(requesterId)

    ---@type MTTeam Здесь никогда не будет `nil`
    ---@diagnostic disable-next-line: assign-type-mismatch
    local team = teamModule.service.getByName(requester.force.name)

    if team.ownerId ~= requester.index then
        error({ configService.getKey('relations:friendly-fire.error-team-not-owner') })
    end

    local friendly_fire = requester.force.friendly_fire == true
    requester.force.friendly_fire = friendly_fire

    requester.force.print({ configService.getKey('relations:friendly-fire.result-template'), team.title,
        configService.getKey('relations:friendly-fire.result-' .. friendly_fire) },
        team.color)
end

return this
