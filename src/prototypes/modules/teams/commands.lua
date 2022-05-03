local this = {}

function this.info(command)
    local player = game.players[command.player_index]
    local team = teams.store.getByName(player.force.name)
    player.print(teams.model.getInfo(team), team.color)
end

function this.list(command)
    local player = game.players[command.player_index]
    for team in teams.store.getAll() do
        player.print(teams.model.getInfo(team), team.color)
    end
end

function this.create(command)
    local owner = game.players[command.player_index]
    local title = command.parameter

    --- Проверка, что есть место для создания команды
    if #game.forces >= 61 then -- 61 - это постоянное значение ограничения
        return owner.print({'teams:errors.reach-force-limit'}, color.red)
    end

    --- Проверка, что название указано
    if title == nil then
        title = getConfig('teams:prefix') .. owner.name
    end

    --- Проверка, что название команды не занято и имя для force свободно
    if teams.store.getByName(title) or teams.store.getByTitle(title) then
        return owner.print({'teams:errors.name-already-used'}, color.red)
    end

    local team = teams.model.create(title, owner)
    game.print({'teams:result.create', team.title}, team.color)
    owner.print({'mod.backstory'}, team.color)
end

function this.name(command)
    local owner = game.players[command.player_index]

    --- Проверка, что это владелец команды
    if not teams.model.isOwner(owner) then
        return owner.print({'teams:errors.not-owner'}, color.red)
    end

    --- Проверка, что новое название команды указано
    local title = command.parameter
    if title == nil then
        return owner.print({'teams:errors.name-not-specified'}, color.red)
    end

    --- Проверка, что название команды не занято
    if teams.store.getByTitle(title) then
        return owner.print({'teams:errors.name-already-used'}, color.red)
    end

    --- Редактируем и сообщаем всем об изменении
    local oldTitle = teams.store.getByName(owner.force.name).title
    local team = teams.model.editTitle(owner.force, title)
    return game.print({'teams:result.edit-name', oldTitle, team.title}, team.color)
end

function this.color(command)
    local owner = game.players[command.player_index]

    --- Проверка, что это владелец команды
    if not teams.model.isOwner(owner) then
        return owner.print({'teams:errors.not-owner'}, color.red)
    end

    --- Проверка, что цвет не тот же самый
    local oldColor = teams.store.getByName(owner.force.name).color
    if owner.color == oldColor then
        return owner.print({'teams:errors.color-already-use'}, color.red)
    end

    --- Редактируем и сообщаем всем об изменении
    local team = teams.model.editColor(owner.force, owner.color)
    return game.print({'teams:result.edit-color', team.title, tostring(oldColor), tostring(team.color)}, team.color)
end

function this.inviteSend(command)
    local owner = game.players[command.player_index]

    --- Проверка, что это владелец команды
    if not teams.model.isOwner(owner) then
        return owner.print({'teams:errors.not-owner'}, color.red)
    end

    --- Проверка, что никнейм указан
    local player = getPlayerByName(command.parameter)
    if player == nil then
        return owner.print({'teams:errors.player-not-found'}, color.red)
    end

    --- Проверка, что ещё не состоит в этой команде
    if owner.force.index == player.force.index then
        return player.print({'teams:errors.player-already-in-team'}, color.red)
    end

    --- Проверка, что приглашения у игрока на рассмотрении нет
    if teams.model.getInvite(player) ~= nil then
        return owner.print({'teams:errors.already-have-invite'}, color.yellow)
    end

    local team = teams.store.invites.set(owner.force, player)
    local timeout = getConfig('teams:invite-timeout')
    owner.print({'teams:result.invite-send', player.name, timeout}, team.color)
    player.print({'teams:events.invite-getted', team.title, timeout}, team.color)
end

function this.inviteAccept(command)
    local player = game.players[command.player_index]

    --- Проверка, что у нас есть приглашение для одобрения
    local invite = teams.model.getInvite(player)
    if invite == nil then
        return player.print({'teams:errors.not-have-invite'}, color.yellow)
    end

    teams.store.invites.remove(player)

    --- Проверка, что команда не была удалена
    local force = game.forces[invite.forceName]
    if force == nil then
        return player.print({'teams:errors.team-not-found'}, color.red)
    end

    local team = teams.model.changeTeamForPlayer(player, force)
    game.print({'teams:result.invite-accepted', player.name, team.title}, team.color)
end

function this.inviteCancel(command)
    local player = game.players[command.player_index]

    --- Проверка, что у нас есть приглашение для отклонения
    local invite = teams.model.getInvite(player)
    if invite == nil then
        return player.print({'teams:errors.not-have-invite'}, color.yellow)
    end

    teams.store.invites.remove(player)

    local team = teams.store.getByName(invite.forceName)
    game.print({'teams:result.invite-canceled', player.name, team.title}, team.color)
end

function this.kick(command)
    local owner = game.players[command.player_index]

    --- Проверка, что это владелец команды
    if not teams.model.isOwner(owner) then
        return owner.print({'teams:errors.not-owner'}, color.red)
    end

    --- Проверка, что никнейм указан
    local player = getPlayerByName(command.parameter)
    if player == nil then
        return owner.print({'teams:errors.player-not-found'}, color.red)
    end

    --- Проверка, что игрок в той же команде
    if owner.force.index ~= player.force.index then
        return owner.print({'teams:errors.player-not-in-team'}, color.red)
    end

    local team = teams.model.kick(player)
    game.print({'teams:result.kick', player.name, team.name}, team.color)
end

function this.change(command)
    local player = game.players[command.player_index]

    --- Проверка, что это администратор
    if not player.admin then
        return game.print({'errors.not-admin', player.name, command.name})
    end

    --- Получение и проверка переданных параметров
    local params = getForceAndPlayerFromParameter(command.parameter)
    if params.force == nil then
        return player.print({'teams:errors.team-not-found'}, color.red)
    end
    if params.player == nil then
        return player.print({'teams:errors.player-not-found'}, color.red)
    end

    --- Проверка, что игрок ещё не состоит в команде
    if params.force.index ~= params.player.force.index then
        return player.print({'teams:errors.player-already-in-team'}, color.red)
    end

    --- Проверка, что это не последний игрок команды
    if #params.player.force.players == 1 then
        teams.model.remove(params.player.force)
    end

    local oldForceName = params.player.force.name
    local team = teams.model.changeTeamForPlayer(params.player, params.force)
    return game.print({'teams:result.change', params.player.name, oldForceName, team.title}, team.color)
end

function this.remove(command)
    local owner = game.players[command.player_index]

    --- Проверка, что это владелец команды
    if not teams.model.isOwner(owner) then
        return owner.print({'teams:errors.not-owner'}, color.red)
    end

    local team = teams.model.remove(owner.force)
    game.print({'teams:result.remove', team.name}, team.color)
end

--- [Локальный метод] Вытащить название команды, а затем никнейм игрока из строки
local function getForceAndPlayerFromParameter(str)
    local result = {
        player = nil,
        force = nil
    }

    if str == nil or trim(str) == '' then
        return result
    end

    --[[
            1. Делим строку на слова по пробелу
            2. Пытаемся искать команду с названием по первому элементу
            2.1 Найдено? Значит остальное имя игрока
            3. Дополняем этот элемент элементом вторым
            3.1 Переходим к п.2.1
    ]] --

    local title = ''
    local hasForce = false
    local nickname = ''
    for word in string.gmatch(str, '[^ ]+') do
        if hasForce then
            nickname = nickname .. ' ' .. word
        else
            title = title .. ' ' .. word
            local team = teams.store.getByTitle(title) -- мы ожидаем именно название команды, а не `force.name`
            if team then
                result.force = game.forces[team.name]
                hasForce = true
            end
        end
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

    if nickname ~= '' then
        result.player = game.players[nickname]
    end

    return result
end

return this
