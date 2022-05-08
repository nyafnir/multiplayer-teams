local this = {}

function this.getInfo(team)
    local owner = getPlayerById(team.ownerId)

    local ownerName = 'нет'
    local countPlayers = 0
    if owner ~= nil then
        ownerName = owner.name
        countPlayers = getSize(owner.force.players)
    else
        countPlayers = getSize(teams.store.forces.get(team.name).players)
    end

    return {'teams:result.info', team.id, team.title, ownerName, countPlayers}
end

function this.create(name, owner)
    local force = teams.store.forces.create(name)
    this.change(owner, force)
    return teams.store.teams.create(force, owner)
end

function this.isOwner(team, player)
    if team.ownerId == player.index then
        return true
    end

    return false
end

function this.hasPlayer(force, player)
    if force.players[player.index] ~= nil then
        return true
    end

    return false
end

function this.editTitle(team, title)
    -- name у force нельзя изменить
    team.title = title
    return team
end

function this.editColor(team, color)
    team.color = color
    return team
end

--- Изменить команду для игрока на указанную
function this.change(player, forceTo)
    player.force = forceTo
end

function this.kick(player)
    local default = teams.store.forces.getDefault()
    this.change(player, default)
end

function this.leave(player)
    this.kick(player)
end

--- Удалить команду (слияние с командой по умолчанию)
function this.remove(name)
    local default = teams.store.forces.getDefault()

    --- Проверяем, что это не команда по умолчанию 
    --- (недоступна для удаления у нас)
    if name == default.name then
        return false
    end

    teams.store.teams.remove(name)
    --- Убраем всех игроков из команды
    local force = teams.store.forces.get(name)
    for _, player in pairs(force.players) do
        this.change(player, default)
    end
    teams.store.forces.remove(name, default.name)

    return true
end

return this
