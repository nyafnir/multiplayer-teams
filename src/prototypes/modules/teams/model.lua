local this = {}

-- @param {LuaForce} force
-- @param {LuaPlayer} [owner]
function this:new(force, owner)
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
function this:getInfo(team)
    local ownerName = getPlayerById(team.ownerId)
    if ownerName == nil then
        ownerName = 'нет'
    end

    return {'teams:result.info', team.id, team.title, ownerName, #player.force.players}
end

function this:create(name, owner)
    local force = game.create_force(name)
    this.changeTeamForPlayer(owner, force)
    return teams.store.add(force, owner)
end

function this:isOwner(player)
    local team = teams.store.getByName(player.force.name)
    if team ~= nil and team.ownerId == player.index then
        return true
    end

    return false
end

function this:hasPlayer(force, player)
    if force.players[player.index] ~= nil then
        return true
    end

    return false
end

function this:editTitle(force, title)
    --- force.name нельзя изменить
    local team = teams.store.getByName(force.name)
    team.title = title
    return team
end

function this:editColor(force, color)
    local team = teams.store.getByName(force.name)
    team.color = color
    return team
end

function this:changeTeamForPlayer(player, force)
    player.force = force
    return teams.store.getByName(force.name)
end

function this:kick(player)
    local default = teams.store.getDefault()
    return this.changeTeamForPlayer(player, default)
end

-- Удалить команду (слияние с командой по умолчанию)
-- @param {LuaForce} force
-- @return {Team} Вернёт объект команды по умолчанию ("Без команды")
function this:remove(force)
    local default = teams.store.getDefault()

    if force ~= default then
        game.merge_forces(force.name, default.name)
    end

    return teams.store.getByName(default.name)
end

return this