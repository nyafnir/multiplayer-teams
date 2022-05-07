local this = {}

function this.getList(forceFrom)
    local list = {
        friends = {},
        enemies = {},
        neutrals = {}
    }

    for nameTo, team in pairs(teams.store.getAll()) do
        local forceTo = teams.store.getForce(nameTo)

        if nameTo == teams.store.getDefaultForce().name or nameTo == forceFrom.name then
            goto relations_base_list_continue
        end

        if forceFrom.is_friend(forceTo) then
            table.insert(list.friends, team.title)
        else
            if forceFrom.is_enemy(forceTo) then
                table.insert(list.enemies, team.title)
            else
                table.insert(list.neutrals, team.title)
            end
        end

        ::relations_base_list_continue::
    end

    return {
        friends = table.concat(list.friends,', '),
        enemies = table.concat(list.enemies,', '),
        neutrals = table.concat(list.neutrals,', '),
    }
end

function this.setEnemy(forceFrom, forceTo)
    if forceFrom.get_friend(forceTo) then
        forceFrom.set_friend(forceTo, false)
    end
end

function this.setNeutral(forceFrom, forceTo)
    if forceFrom.get_friend(forceTo) then
        forceFrom.set_friend(forceTo, false)
    end
end

function this.setFriend(forceFrom, forceTo)
    if not forceFrom.get_friend(forceTo) then
        forceFrom.set_friend(forceTo, true)
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
