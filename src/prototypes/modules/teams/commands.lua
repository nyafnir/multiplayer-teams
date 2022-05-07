local this = {}

--- [Локальный метод] Вытащить название команды, а затем никнейм игрока из строки
local function getForceAndPlayerFromParameter(str)
    local result = {
        player = nil,
        force = nil
    }

    logger('Got string: ' .. tostring(str))
    if str == nil or str == ' ' then
        return result
    end

    --[[
            1. Делим строку на слова по пробелу
            2. Пытаемся искать команду с названием по первому элементу
            2.1 Найдено? Значит остальное имя игрока
            3. Дополняем этот элемент элементом вторым
            3.1 Переходим к п.2.1
    ]] --

    local title = nil
    local nickname = nil
    for word in string.gmatch(str, '[^ ]+') do
        if result.force ~= nil then
            if nickname == nil then
                nickname = word
            else
                nickname = nickname .. ' ' .. word
            end
        else
            if title == nil then
                title = word
            else
                title = title .. ' ' .. word
            end

            local team = teams.store.getByTitle(title) -- мы ожидаем именно название команды, а не `force.name`
            if team ~= nil then
                result.force = teams.store.getForce(team.name)
            end
        end
    end

    if nickname ~= '' then
        result.player = getPlayerByName(nickname)
    end

    -- SUGG-1: Алгоритм можно расширить сделав перебор до
    -- момента нахождения обоих параметров и команды и игрока:
    --         team1=команда хом ы
    --         team2=команда
    --         player=игр ок

    -- SUGG-2: Опираясь на то что через factorio.com подключен ник в игру
    -- возможно нужно развернуть for 
    -- сделав перебор с конца к началу, от игрока к команде
    -- но я не знаю что можно написать если отвязать аккаунт

    return result
end

function this.info(command)
    local player = getPlayerById(command.player_index)
    local team = teams.store.getByName(player.force.name)
    player.print(teams.model.getInfo(team), team.color)
end

function this.list(command)
    local player = getPlayerById(command.player_index)
    for _, team in pairs(teams.store.getAll()) do
        player.print(teams.model.getInfo(team), team.color)
    end
end

function this.create(command)
    local owner = getPlayerById(command.player_index)
    local title = command.parameter

    --- Проверка, что без команды
    if owner.force.index ~= teams.store.getDefaultForce().index then
        return player.print({'teams:errors.player-already-in-team'}, colors.red)
    end

    --- Проверка, что есть место для создания команды
    if getSize(teams.store.getForces()) >= 61 then -- 61 - это постоянное значение ограничения
        return owner.print({'teams:errors.reach-force-limit'}, colors.red)
    end

    --- Проверка, что название указано
    if title == nil then
        title = owner.name
    end

    --- Проверка, что название команды не занято и имя для force свободно
    if teams.store.getByName(title) ~= nil or teams.store.getByTitle(title) ~= nil then
        return owner.print({'teams:errors.title-already-used'}, colors.red)
    end

    local team = teams.model.create(title, owner)
    game.print({'teams:result.create', team.title}, team.color)
    owner.print({'mod.backstory'}, team.color)
end

function this.name(command)
    local owner = getPlayerById(command.player_index)

    --- Проверка, что это владелец команды
    if not teams.model.isOwner(owner) then
        return owner.print({'teams:errors.not-permission-owner'}, colors.red)
    end

    --- Проверка, что новое название команды указано
    local title = command.parameter
    if title == nil then
        return owner.print({'teams:errors.title-not-specified'}, colors.red)
    end

    --- Проверка, что название команды не занято
    if teams.store.getByTitle(title) ~= nil then
        return owner.print({'teams:errors.title-already-used'}, colors.red)
    end

    --- Редактируем и сообщаем всем об изменении
    local oldTitle = teams.store.getByName(owner.force.name).title
    local team = teams.model.editTitle(owner.force, title)
    return game.print({'teams:result.edit-name', oldTitle, team.title}, team.color)
end

function this.color(command)
    local owner = getPlayerById(command.player_index)

    --- Проверка, что это владелец команды
    if not teams.model.isOwner(owner) then
        return owner.print({'teams:errors.not-permission-owner'}, colors.red)
    end

    --- Проверка, что цвет не тот же самый
    local oldColor = teams.store.getByName(owner.force.name).color
    if isEqualRGBAColors(owner.color, oldColor) then
        return owner.print({'teams:errors.color-already-use'}, colors.red)
    end

    --- Редактируем и сообщаем всем об изменении
    local team = teams.model.editColor(owner.force, owner.color)
    return game.print({'teams:result.edit-color', team.title}, team.color)
end

function this.inviteSend(command)
    local owner = getPlayerById(command.player_index)

    --- Проверка, что это владелец команды
    if not teams.model.isOwner(owner) then
        return owner.print({'teams:errors.not-permission-owner'}, colors.red)
    end

    --- Проверка, что никнейм указан
    local player = getPlayerByName(command.parameter)
    if player == nil then
        return owner.print({'teams:errors.player-not-found'}, colors.red)
    end

    --- Проверка, что без команды
    if player.force.index ~= teams.store.getDefaultForce().index then
        return player.print({'teams:errors.player-already-in-team'}, colors.red)
    end

    local timeout = getConfig('teams:invite-timeout')

    --- Проверка, что приглашения у игрока на рассмотрении нет
    if teams.store.invites.get(player) ~= nil then
        return owner.print({'teams:errors.already-have-invite', timeout}, colors.yellow)
    end

    teams.store.invites.set(owner.force, player)

    local team = teams.store.getByName(owner.force.name)
    owner.print({'teams:result.invite-send', player.name, timeout}, team.color)
    player.print({'teams:events.invite-getted', team.title, timeout}, team.color)
end

function this.inviteAccept(command)
    local player = getPlayerById(command.player_index)

    --- Проверка, что у нас есть приглашение для одобрения
    local invite = teams.store.invites.get(player)
    if invite == nil then
        return player.print({'teams:errors.not-have-invite'}, colors.yellow)
    end

    teams.store.invites.remove(player)

    --- Проверка, что команда не была удалена
    local force = teams.store.getForce(invite.forceName)
    if force == nil then
        return player.print({'teams:errors.team-not-found'}, colors.red)
    end

    local team = teams.model.changeTeamForPlayer(player, force)
    game.print({'teams:events.invite-accepted', player.name, team.title}, team.color)
end

function this.inviteCancel(command)
    local player = getPlayerById(command.player_index)

    --- Проверка, что у нас есть приглашение для отклонения
    local invite = teams.store.invites.get(player)
    if invite == nil then
        return player.print({'teams:errors.not-have-invite'}, colors.yellow)
    end

    teams.store.invites.remove(player)

    local team = teams.store.getByName(invite.forceName)
    game.print({'teams:events.invite-canceled', player.name, team.title}, team.color)
end

function this.kick(command)
    local owner = getPlayerById(command.player_index)

    --- Проверка, что это владелец команды
    if not teams.model.isOwner(owner) then
        return owner.print({'teams:errors.not-permission-owner'}, colors.red)
    end

    --- Проверка, что никнейм указан
    local player = getPlayerByName(command.parameter)
    if player == nil then
        return owner.print({'teams:errors.player-not-found'}, colors.red)
    end

    --- Проверка, что игрок в той же команде
    if owner.force.index ~= player.force.index then
        return owner.print({'teams:errors.player-not-in-team'}, colors.red)
    end

    --- Проверка, что это не лидер
    if owner == player then
        return owner.print({'teams:errors.can-t-kick-owner'}, colors.red)
    end

    local oldTeam = teams.store.getByName(owner.force.name)
    teams.model.kick(player)
    game.print({'teams:result.kick', player.name, oldTeam.title}, oldTeam.color)
end

function this.change(command)
    local player = getPlayerById(command.player_index)

    --- Проверка, что это администратор
    if not player.admin then
        return game.print({'errors.not-admin', player.name, command.name})
    end

    --- Получение и проверка переданных параметров
    local params = getForceAndPlayerFromParameter(command.parameter)
    if params.force == nil then
        return player.print({'teams:errors.team-not-found'}, colors.red)
    end
    if params.player == nil then
        return player.print({'teams:errors.player-not-found'}, colors.red)
    end

    --- Проверка, что игрок ещё не состоит в команде
    if params.force.index == params.player.force.index then
        return player.print({'teams:errors.player-already-in-team'}, colors.red)
    end

    local oldTitle = teams.store.getByName(params.player.force.name).title

    --- Проверка, что это не последний игрок команды
    if getSize(params.player.force.players) == 1 then
        teams.model.remove(params.player.force)
    end

    local team = teams.model.changeTeamForPlayer(params.player, params.force)
    return game.print({'teams:result.change', params.player.name, oldTitle, team.title}, team.color)
end

function this.remove(command)
    local owner = getPlayerById(command.player_index)

    --- Проверка, что это владелец команды
    if not teams.model.isOwner(owner) then
        return owner.print({'teams:errors.not-permission-owner'}, colors.red)
    end

    local oldTeam = teams.store.getByName(owner.force.name)
    local oldTitle = oldTeam.title
    local oldColor = oldTeam.color
    teams.model.remove(owner.force)
    game.print({'teams:result.remove', oldTitle}, oldColor)
end

function this.leave(command)
    local player = getPlayerById(command.player_index)

    --- Проверка, что это не владелец команды
    if teams.model.isOwner(player) then
        return player.print({'teams:errors.can-t-leave-owner'}, colors.red)
    end

    --- Проверка, что в команде
    if player.force.index == teams.store.getDefaultForce().index then
        return player.print({'teams:errors.not-have-team'}, colors.red)
    end

    local oldTeam = teams.store.getByName(player.force.name)
    local oldTitle = oldTeam.title
    local oldColor = oldTeam.color
    teams.model.leave(player)
    game.print({'teams:result.leave', player.name, oldTitle}, oldColor)
end

return this
