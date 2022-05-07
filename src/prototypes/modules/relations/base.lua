local this = {}

function this.getList(forceFrom)
    local list = {
        friends = '',
        enemies = '',
        neutrals = ''
    }

    for nameTo, team in pairs(teams.store.getAll()) do
        local forceTo = teams.store.getForce(nameTo)

        if nameTo == teams.store.getDefaultForce().name then
            goto relations_base_list_continue
        end

        if forceFrom.is_friend(forceTo) then
            list.friends = list.friends .. team.title .. ' '
        else
            if forceFrom.is_enemy(forceTo) then
                list.enemies = list.enemies .. team.title .. ' '
            else
                list.neutrals = list.neutrals .. team.title .. ' '
            end
        end

        ::relations_base_list_continue::
    end

    return list
end

function this.setEnemy(forceFrom, forceTo)
    if forceFrom.get_friend(forceTo) then
        forceFrom.set_friend(forceTo, false)
    end
    if forceFrom.get_cease_fire(forceTo) then
        forceFrom.set_cease_fire(forceTo, false)
    end
end

function this.setNeutral(forceFrom, forceTo)
    if forceFrom.get_friend(forceTo) then
        forceFrom.set_friend(forceTo, false)
    end
    if not forceFrom.get_cease_fire(forceTo) then
        forceFrom.set_cease_fire(forceTo, true)
    end
end

function this.setFriend(forceFrom, forceTo)
    if not forceFrom.get_friend(forceTo) then
        forceFrom.set_friend(forceTo, true)
    end
    if relations.config.hasFriendlyFire and not forceFrom.get_cease_fire(forceTo) then
        forceFrom.set_cease_fire(forceTo, true)
    end
end

function this.setOffer(forceFromName, forceToName, ownerToId)
    relations.store.offers.set(forceFromName, forceToName, ownerToId)
end

function this.getOffer(ownerToId)
    relations.store.offers.get(ownerToId)
end

function this.removeOffer(ownerToId)
    relations.store.offers.remove(ownerToId)
end

return this
