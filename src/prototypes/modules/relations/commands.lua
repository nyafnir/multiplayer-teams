local this = {}

function this.list(command)
    local player = getPlayerById(command.player_index)

    local list = relations.base.list(player.force)

    player.print({'relations:result.info-friend', list.friends}, color.green)
    player.print({'relations:result.info-enemy', list.enemies}, color.red)
    player.print({'relations:result.info-neutrals', list.neutrals}, color.grey)
end

function this.enemy(command)
    local player = getPlayerById(command.player_index)

    --- Проверка, что это лидер команды
    if not teams.model.isOwner(player) then
        return player.print({'relations:error.not-owner'}, color.red)
    end

    --- Проверка, что указано название другой команды
    if command.parameter == nil then
        return player.print({'relations:error.not-title'}, color.red)
    end

    --- Проверка, что команда существует в нашей базе
    local teamTo = teams.store.getByName(command.parameter)
    if teamTo == nil then
        return player.print({'relations:error.not-found'}, color.red)
    end

    --- Проверка, что это не "Без команды"
    if teamTo.index == teams.store.getDefaultForce().index then
        return player.print({'relations:error.not-found'}, color.red)
    end

    relations.base.enemy(player.force, teams.store.getForce((teamTo.name)))

    local teamFrom = teams.store.getByName(player.force.name)
    game.print({'relations:event.enemy', teamFrom.title, teamTo.title}, color.red)
end

function this.neutral(command)
    local player = getPlayerById(command.player_index)

    --- Проверка, что это лидер команды
    if not teams.model.isOwner(player) then
        return player.print({'relations:error.not-owner'}, color.red)
    end

    --- Проверка, что указано название другой команды
    if command.parameter == nil then
        return player.print({'relations:error.not-title'}, color.red)
    end

    --- Проверка, что команда существует в нашей базе
    local teamTo = teams.store.getByName(command.parameter)
    if teamTo == nil then
        return player.print({'relations:error.not-found'}, color.red)
    end

    --- Проверка, что это не "Без команды"
    if teamTo.index == teams.store.getDefaultForce().index then
        return player.print({'relations:error.not-found'}, color.red)
    end

    relations.base.neutral(forceFrom, forceTo)

    local teamFrom = teams.store.getByName(forceFrom.name)
    local teamTo = teams.store.getByName(forceTo.name)

    game.print({'relations:event.neutral', teamFrom.title, teamTo.title}, color.grey)

end

function this.friend(command)
    local player = getPlayerById(command.player_index)

    --- Проверка, что это лидер команды
    if not teams.model.isOwner(player) then
        return player.print({'relations:error.not-owner'}, color.red)
    end

    --- Проверка, что указано название другой команды
    if command.parameter == nil then
        return player.print({'relations:error.not-title'}, color.red)
    end

    --- Проверка, что команда существует в нашей базе
    local teamTo = teams.store.getByName(command.parameter)
    if teamTo == nil then
        return player.print({'relations:error.not-found'}, color.red)
    end

    --- Проверка, что это не "Без команды"
    if teamTo.index == teams.store.getDefaultForce().index then
        return player.print({'relations:error.not-found'}, color.red)
    end

    relations.base.friend(forceFrom, forceTo)

    local teamFrom = teams.store.getByName(forceFrom.name)
    local teamTo = teams.store.getByName(forceTo.name)

    game.print({'relations:event.friend', teamFrom.title, teamTo.title}, color.green)
end

return this
