local this = {
    invites = {
        data = {} -- invites[playerId] = forceName
    }
}

script.on_nth_tick(60 * 60 * tonumber(getConfig('teams:invite-timeout')), function(event)
    if #this.invites.data == 0 then
        return
    end

    for playerId, data in this.invites.data do
        if data.date <= os.date() then
            data = nil
        end
    end
end)

function this.getDefault()
    return game.forces[getConfig('teams:defaultForceName')]
end

--- Добавляем команду по умолчанию
local function addDefaultTeam()
    local team = teams.model.new(this.getDefault(), nil)
    team.name = 'Без команды'
    this.insert(team)
end

function this.init()
    global.teams = {}
    addDefaultTeam()
end

function this.load()
    if global.teams == nil then
        this.init()
        --- Если модуль не был инициализирован в начале игры, то он возьмёт данные по командам из игры
        for forceName, force in pairs(game.forces) do
            -- команды нет в нашем модуле?
            if forceName ~= 'player' and forceName ~= 'enemy' and forceName ~= 'neutral' and this.getByName(forceName) ~=
                nil then
                -- тогда добавляем
                local owner = force.players[0] or force.players[1]
                this.add(force, owner)
            end
        end
    end
end

function this.insert(team)
    global.teams[team.name] = team
    return team
end

function this.add(force, owner)
    return this.insert(teams.model.new(force, owner))
end

function this.getByName(teamName)
    return global.teams[teamName]
end

function this.getById(teamId)
    for team in global.teams do
        if team.id == teamId then
            return team
        end
    end

    return nil
end

function this.getByTitle(title)
    for team in global.teams do
        if team.title == title then
            return team
        end
    end

    return nil
end

function this.getAll()
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
