local this = {}

local function init()
    if global.teams ~= nil or next(global.teams) then
        return
    end

    --- Добавляем команду по умолчанию
    local forceDefault = teams.store.forces.getDefault()
    local teamDefault = teams.model.new(forceDefault, nil)
    teamDefault.title = 'Без команды'
    global.teams = {
        [teamDefault.name] = forceDefault
    }

    --- Если модуль не был инициализирован в начале, то он возьмёт данные по командам игроков из игры
    for forceName, force in pairs(teams.store.forces.getAll()) do
        --- Команды по умолчанию пропускаем
        if forceName == 'player' or forceName == 'enemy' or forceName == 'neutral' then
            goto continue
        end
        --- Такая команда есть в нашем модуле?
        if this.getByName(forceName) == nil then
            --- тогда добавляем
            local owner = force.players[1]
            this.add(force, owner)
        end

        ::continue::
    end

end

function this.getAll()
    init()
    return global.teams
end

function this.add(team)
    this.getAll()[team.name] = team
    return team
end

function this.create(force, owner)
    return this.add(teams.model.new(force, owner))
end

function this.remove(name)
    local default = teams.store.forces.getDefault()

    --- Проверяем, что это не команда по умолчанию (недоступна для удаления у нас)
    if name ~= default.name then
        --- Убраем всех игроков из команды
        local force = teams.store.forces.get(name)
        for _, player in pairs(force.players) do
            teams.model.changeTeamForPlayer(player, default)
        end
        --- Удаляем `force`
        game.merge_forces(name, default.name)
        --- Удаляем `team`
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

return this
