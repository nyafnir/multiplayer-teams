local this = {}

--- relation = enemy | neutral | friend, иначе ничего не произойдёт
local function changeRelation(ownerFromId, teamToTitle, relation)
    local ownerFrom = getPlayerById(ownerFromId)

    if teamToTitle == nil then --- Проверка, что указано название команды игроков
        return ownerFrom.print({'relations:error.not-team-title'}, colors.red)
    end

    local teamTo = teams.store.teams.getByName(teamToTitle)
    --- Проверка, что команда игроков существует
    --- Проверка, что это не "Без команды"
    if teamTo == nil or teams.store.forces.getDefault().name == teamTo.name then
        return ownerFrom.print({'relations:error.not-found-team'}, colors.red)
    end
    local forceTo = teams.store.forces.get(teamTo.name)

    local forceFrom = ownerFrom.force
    local teamFrom = teams.store.teams.getByName(forceFrom.name)
    if teamFrom.ownerId ~= ownerFromId then --- Проверка, что это лидер своей команды
        return ownerFrom.print({'relations:error.not-owner'}, colors.red)
    end

    local ownerTo = getPlayerById(teamTo.ownerId)

    --- Проверка, что нет заявок на расммотрении у другой команды
    local offer = relations.store.offers.get(ownerTo.index)
    if offer ~= nil then --- Проверка, что есть заявка
        return ownerFrom.print({'relations:error.already-has-offer', relations.config.offer.timeout.minutes},
            colors.yellow)
    end

    if relation == 'enemy' then --- заявка никогда не нужна
        if forceFrom.is_enemy(forceTo) then --- Проверка, что предложенных отношений ещё нет
            return ownerFrom.print({'relations:error.already-has-the-relation'}, colors.red)
        end

        relations.base.setEnemy(forceFrom, forceTo)

        return game.print({'relations:event.become-enemies', teamFrom.title, teamTo.title}, colors.red)
    end

    if relation == 'friend' then --- заявка всегда нужна
        if forceFrom.is_friend(forceTo) then --- Проверка, что предложенных отношений ещё нет
            return ownerFrom.print({'relations:error.already-has-the-relation'}, colors.red)
        end

        relations.store.offers.set(teamFrom.name, teamTo.name, teamTo.ownerId, 'friend')

        ownerFrom.print({'relations:event.offer-friend-sended', teamTo.title}, teamTo.color)
        ownerTo.print({'relations:event.offer-friend-getted', teamFrom.title}, teamTo.color)

        return
    end

    if relation == 'neutral' then
        --- Проверка, что предложенных отношений ещё нет
        if not forceFrom.is_enemy(forceTo) and not forceFrom.is_friend(forceTo) then
            return ownerFrom.print({'relations:error.already-has-the-relation'}, colors.red)
        end

        if forceFrom.is_friend(forceTo) then --- заявка не нужна, если друзья
            relations.base.setNeutral(forceFrom, forceTo)
            game.print({'relations:event.become-neutral', teamFrom.title, teamTo.title}, colors.grey)
        else
            relations.store.offers.set(teamFrom.name, teamTo.name, teamTo.ownerId, 'neutral')

            ownerFrom.print({'relations:event.offer-neutral-sended', teamTo.title}, teamTo.color)
            ownerTo.print({'relations:event.offer-neutral-getted', teamFrom.title}, teamTo.color)
        end

        return
    end
end

local function changeOffer(ownerToId, isAccept)
    local ownerTo = getPlayerById(ownerToId)

    local offer = relations.store.offers.get(ownerTo.index)
    if offer == nil then --- Проверка, что есть заявка
        return ownerTo.print({'relations:error.not-offer'}, colors.yellow)
    end

    relations.store.offers.remove(ownerTo.index)

    local forceFrom = teams.store.forces.get(offer.forceFromName)
    local forceTo = ownerTo.force

    local teamFrom = teams.store.teams.getByName(offer.forceFromName)
    local teamTo = teams.store.teams.getByName(offer.forceToName)

    local ownerFrom = getPlayerById(teamFrom.ownerId)

    if offer.relation == 'neutral' then
        if isAccept then
            relations.base.setNeutral(forceFrom, forceTo)
            game.print({'relations:event.offer-neutral-accepted', teamFrom.title, teamTo.title}, colors.grey)
        else
            ownerFrom.print({'relations:event.offer-neutral-canceled', teamTo.title}, colors.red)
        end
        return
    end

    if offer.relation == 'friend' then
        if isAccept then
            relations.base.setFriend(forceFrom, forceTo)
            game.print({'relations:event.offer-friend-accepted', teamFrom.title, teamTo.title}, colors.green)
        else
            ownerFrom.print({'relations:event.offer-friend-canceled', teamTo.title}, colors.red)
        end
    end
end

function this.addCmds()
    -- Если первой консольной команды нет, значит и других нет, тогда загружаем их
    if commands.commands['relations'] == nil then
        commands.add_command('relations', {'relations:help.get-list'}, this.getList)
        commands.add_command('relation-enemy', {'relations:help.set-enemy'}, this.setEnemy)
        commands.add_command('relation-neutral', {'relations:help.set-neutral'}, this.setNeutral)
        commands.add_command('relation-friend', {'relations:help.set-friend'}, this.setFriend)
        commands.add_command('relation-accept', {'relations:help.offer-accept'}, this.acceptOffer)
        commands.add_command('relation-cancel', {'relations:help.offer-cancel'}, this.cancelOffer)
    end
end

function this.getList(command)
    local owner = getPlayerById(command.player_index)
    local list = relations.base.getList(owner.force)

    owner.print({'relations:result.list-friends', list.friends}, colors.green)
    owner.print({'relations:result.list-enemies', list.enemies}, colors.red)
    owner.print({'relations:result.list-neutrals', list.neutrals}, colors.grey)
end

function this.setEnemy(command)
    changeRelation(command.player_index, command.parameter, 'enemy')
end

function this.setNeutral(command)
    changeRelation(command.player_index, command.parameter, 'neutral')
end

function this.setFriend(command)
    changeRelation(command.player_index, command.parameter, 'friend')
end

function this.acceptOffer(command)
    changeOffer(command.player_index, true)
end

function this.cancelOffer(command)
    changeOffer(command.player_index, false)
end

return this
