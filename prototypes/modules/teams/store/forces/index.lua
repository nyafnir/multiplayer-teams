local this = {}

function this.create(name)
    return game.create_force(name)
end

function this.getDefault()
    return this.get(teams.config.default.forceName)
end

function this.getAll()
    return game.forces
end

function this.get(name)
    if name == nil then
        return nil
    end

    return this.getAll()[name]
end

function this.merge(name, forceToNameMerge)
    if forceToNameMerge == nil then
        forceToNameMerge = teams.store.forces.getDefault().name
    end

    --- Сливаем `force` в указанную команду
    game.merge_forces(name, forceToNameMerge)
end

function this.remove(name, forceToNameMerge)
    this.merge(name, forceToNameMerge)
end

return this
