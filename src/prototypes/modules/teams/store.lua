local this = {
    invites = {
        data = {} -- invites[playerId] = forceName
    }
}

local timeout = 60 * 60 * tonumber(getConfig('teams:invite-timeout')) -- ticks

script.on_nth_tick(timeout, function(event)
    if event == nil then
        return
    end

    if not next(teams.store.invites.data) then
        return
    end

    for playerId, data in pairs(teams.store.invites.data) do
        if data.createdAt + timeout <= getPlayerById(playerId).online_time then
            data = nil
        end
    end
end)

function this.insert(team)
    this.getAll()[team.name] = team
    return team
end

function this.add(force, owner)
    return this.insert(teams.model.new(force, owner))
end

function this.remove(name)
    local default = teams.store.getDefaultForce()

    if name ~= default.name then
        --- Убраем всех игроков из команды
        local force = this.getForce(force.name)
        for _, player in pairs(force.players) do
            teams.model.changeTeamForPlayer(player, default)
        end
        --- Удаляем из force
        game.merge_forces(name, default.name)
        --- Удаляем из teams
        this.getAll()[name] = nil
    end

    return this.getAll()[default.name]
end

function this.getByName(teamName)
    return this.getAll()[teamName]
end

function this.getById(teamId)
    for _, team in pairs(this.getAll()) do
        if team.id == teamId then
            return team
        end
    end

    return nil
end

function this.getByTitle(title)
    for _, team in pairs(this.getAll()) do
        if team.title == title then
            return team
        end
    end

    return nil
end

function this.getDefaultForce()
    return this.getForce(getConfig('teams:defaultForceName'))
end

function this.getAll()
    if global.teams == nil or not next(global.teams) then
        --- Добавляем команду по умолчанию
        local default = teams.model.new(this.getDefaultForce(), nil)
        default.title = 'Без команды'

        global.teams = {
            [this.getDefaultForce().name] = default
        }

        --- Если модуль не был инициализирован в начале игры, то он возьмёт данные по командам из игры
        for forceName, force in pairs(this.getForces()) do
            -- команды нет в нашем модуле?
            if forceName ~= 'player' and forceName ~= 'enemy' and forceName ~= 'neutral' and this.getByName(forceName) ==
                nil then
                -- тогда добавляем
                local owner = force.players[0] or force.players[1]
                this.add(force, owner)
            end
        end
    end

    return global.teams
end

function this.invites.get(player)
    return this.invites.data[player.index]
end

function this.invites.set(force, player)
    this.invites.data[player.index] = {
        forceName = force.name,
        createdAt = player.online_time -- ticks
    }
end

function this.invites.remove(player)
    this.invites.data[player.index] = nil
end

function this.getForce(name)
    return this.getForces()[name]
end

function this.getForces()
    return game.forces
end

return this
