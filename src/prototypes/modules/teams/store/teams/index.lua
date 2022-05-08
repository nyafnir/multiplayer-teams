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

function this.create(force, owner)
    local team = {
        id = force.index,
        name = force.name, --- оригинальное имя, никогда не меняется
        title = force.name, --- отображаемое имя, может меняться
        color = colors.white,
        ownerId = nil
    }

    if owner ~= nil then
        team.color = owner.color
        team.ownerId = owner.index
    end

    this.getAll()[team.name] = team

    return team
end

function this.remove(name)
    --- Удаляем `team`
    this.getAll()[name] = nil
end

function this.getByName(name)
    return this.getAll()[name]
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
