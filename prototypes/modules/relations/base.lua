local this = {}

function this.getList(forceFrom)
    local result = {
        friends = {},
        enemies = {},
        neutrals = {}
    }

    local list = teams.store.teams.getAll()
    local default = teams.store.forces.getDefault()
    for nameTo, team in pairs(list) do
        local forceTo = teams.store.forces.get(nameTo)

        if nameTo == default.name or nameTo == forceFrom.name then
            goto relations_base_list_continue
        end

        if forceFrom.is_friend(forceTo) then
            table.insert(result.friends, team.title)
        else
            if forceFrom.is_enemy(forceTo) then
                table.insert(result.enemies, team.title)
            else
                table.insert(result.neutrals, team.title)
            end
        end

        ::relations_base_list_continue::
    end

    return {
        friends = table.concat(result.friends, ', '),
        enemies = table.concat(result.enemies, ', '),
        neutrals = table.concat(result.neutrals, ', ')
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

function this.getOffer(ownerToId) relations.store.offers.get(ownerToId) end

function this.removeOffer(ownerToId) relations.store.offers.remove(ownerToId) end

return this

-- function this.switchFriendlyFire(command)
--     local player = playerService.getById(command.player_index)
-- game.player.force.friendly_fire = false -- FROM OFF DOC!
--     player.force.set_cease_fire(player.force, force.friendly_fire == false)
-- end