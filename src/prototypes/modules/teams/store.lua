local this = {
    invites = {
        data = {} -- invites[playerId] = forceName
    }
}

script.on_nth_tick(60 * 60 * getConfig('teams:invite-timeout'), function(event)
    for playerId, data in this.invites.data do
        if data.date <= os.date() then
            data = nil
        end
    end
end)

function this:getDefault()
    return game.forces[getConfig('teams:defaultForceName')]
end

function this:init()
    if global.teams == nil then
        global.teams = {}

        --- Добавляем команду по умолчанию
        local team = teams.model.new(this.getDefault(), nil)
        team.name = 'Без команды'
        this.insert(team)
    end
end

function this:load()
    --- Если модуль не был инициализирован в начале игры, то он возьмёт данные по командам из игры
    for force in game.forces do
        -- команды нет в нашем модуле?
        if this.getByName(force.name) ~= nil then
            -- тогда добавляем
            local owner = force.players[0] or force.players[1]
            this.add(force, owner)
        end
    end
end

function this:insert(team)
    global.teams.insert(team.name, team)
    return team
end

function this:add(force, owner)
    return this.insert(teams.model.new(force, owner))
end

function this:getByName(teamName)
    return global.teams[teamName]
end

function this:getById(teamId)
    for team in global.teams do
        if team.id == teamId then
            return team
        end
    end

    return nil
end

function this:getByTitle(title)
    for team in global.teams do
        if team.title == title then
            return team
        end
    end

    return nil
end

function this:getAll()
    return global.teams or {}
end

function this.invites:get(player)
    return this.invites.data[player.index]
end

function this.invites:set(force, player)
    this.invites.data[player.index] = {
        forceName = force.name,
        date = os.date()
    }
end

function this.invites:remove(player)
    this.invites.data[player.index] = nil
end

return this