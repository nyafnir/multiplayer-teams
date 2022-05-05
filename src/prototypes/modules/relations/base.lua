local this = {}

function this.list(forceFrom)
    local list = {
        friends = '',
        enemies = '',
        neutrals = ''
    }

    for nameTo, forceTo in pairs(teams.store.getForces()) do
        local team = teams.store.getByName(nameTo)

        if forceFrom.is_friend(forceTo) then
            list.friends = friends .. team.title .. ' '
        else
            if forceFrom.is_enemy(forceTo) then
                list.enemies = enemies .. team.title .. ' '
            else
                if nameTo == teams.store.getDefaultForce().name then
                    goto relations_commands_list_continue
                end
                list.neutrals = neutrals .. team.title .. ' '
            end
        end

        ::relations_commands_list_continue::
    end

    return list
end

function this.enemy(forceFrom, forceTo)
    if forceFrom.get_friend(forceTo) then
        forceFrom.set_friend(forceTo, false)
    end
    if forceFrom.get_cease_fire(forceTo) then
        forceFrom.set_cease_fire(forceTo, false)
    end
end

function this.neutral(forceFrom, forceTo)
    if forceFrom.get_friend(forceTo) then
        forceFrom.set_friend(forceTo, false)
    end
    if not forceFrom.get_cease_fire(forceTo) then
        forceFrom.set_cease_fire(forceTo, true)
    end
end

function this.friend(forceFrom, forceTo)
    if not forceFrom.get_friend(forceTo) then
        forceFrom.set_friend(forceTo, true)
    end
    if not forceFrom.get_cease_fire(forceTo) then
        forceFrom.set_cease_fire(forceTo, true)
    end
end

return this
