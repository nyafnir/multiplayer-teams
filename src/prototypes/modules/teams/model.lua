local this = {}

-- @param {LuaForce} force
-- @param {LuaPlayer} [owner]
function this.new(force, owner)
    local team = {
        id = force.index,
        name = force.name, --- оригинальное имя, никогда не меняется
        title = force.name, --- отображаемое имя, можно менять
        color = color.white,
        ownerId = nil
    }

    if owner ~= nil then
        team.color = owner.color
        team.ownerId = owner.index
    end

    return team
end

-- @return {string}
function this.getInfo(team)
    local owner = getPlayerById(team.ownerId)

    local ownerName = 'нет'
    local countPlayers = 0
    if owner ~= nil then
        ownerName = owner.name
        countPlayers = getSize(owner.force.players)
    else
        countPlayers = getSize(teams.store.getForce(team.name).players)
    end

    return {'teams:result.info', team.id, team.title, ownerName, countPlayers}
end

function this.create(name, owner)
    local force = game.create_force(name)
    this.changeTeamForPlayer(owner, force)
    return teams.store.add(force, owner)
end

function this.isOwner(player)
    local team = teams.store.getByName(player.force.name)
    if team ~= nil and team.ownerId == player.index then
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

function this.editTitle(force, title)
    --- force.name нельзя изменить
    local team = teams.store.getByName(force.name)
    team.title = title
    return team
end

function this.editColor(force, color)
    local team = teams.store.getByName(force.name)
    team.color = color
    return team
end

function this.changeTeamForPlayer(player, force)
    player.force = force
    return teams.store.getByName(force.name)
end

function this.kick(player)
    local default = teams.store.getDefaultForce()
    return this.changeTeamForPlayer(player, default)
end

function this.leave(player)
    local default = teams.store.getDefaultForce()
    return this.changeTeamForPlayer(player, default)
end

-- Удалить команду (слияние с командой по умолчанию)
-- @param {LuaForce} force
-- @return {Team} Вернёт объект команды по умолчанию ("Без команды")
function this.remove(force)
    return teams.store.remove(force.name)
end

return this
