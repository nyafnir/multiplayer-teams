local this = {}

function this.getDefault()
    return this.get(teams.config.default.forceName)
end

function this.get(name)
    if name == nil then
        return nil
    end

    return this.getAll()[name]
end

function this.getAll()
    return game.forces
end

return this
