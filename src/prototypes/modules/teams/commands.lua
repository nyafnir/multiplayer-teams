local this = {}

function this.addCmds()
    -- Если консольной команды "информации о команде" нет, значит и других нет, тогда загружаем их
    if commands.commands['team'] ~= nil then
        return
    end

    commands.add_command('team', {'teams:help.info'}, teams.commands.info)
    commands.add_command('teams', {'teams:help.list'}, teams.commands.list)
    commands.add_command('team-create', {'teams:help.create'}, teams.commands.create)
    commands.add_command('team-name', {'teams:help.edit-name'}, teams.commands.setName)
    commands.add_command('team-color', {'teams:help.edit-color'}, teams.commands.setColor)
    commands.add_command('team-invite', {'teams:help.invite-send'}, teams.commands.inviteSend)
    commands.add_command('team-invite-accept', {'teams:help.invite-accept'}, teams.commands.inviteAccept)
    commands.add_command('team-invite-cancel', {'teams:help.invite-cancel'}, teams.commands.inviteCancel)
    commands.add_command('team-kick', {'teams:help.kick'}, teams.commands.kick)
    commands.add_command('team-change', {'teams:help.change'}, teams.commands.change)
    commands.add_command('team-remove', {'teams:help.remove'}, teams.commands.remove)
    commands.add_command('team-leave', {'teams:help.leave'}, teams.commands.leave)
end

--- Вытаскивает название команды игроков, а затем ник игрока из строки
local function getForceAndPlayerFromParameter(str)
    local result = {
        player = nil,
        force = nil,
        team = nil
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

            -- мы ожидаем именно название команды, а не `force.name`
            local team = teams.store.teams.getByTitle(title)
            if team ~= nil then
                result.team = team
                result.force = teams.store.forces.get(team.name)
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
    local team = teams.store.teams.getByName(player.force.name)
    player.print(teams.base.getInfo(team), team.color)
end

function this.list(command)
    local player = getPlayerById(command.player_index)
    player.print({'teams:result.list'}, colors.white)
    for _, team in pairs(teams.store.teams.getAll()) do
        player.print(teams.base.getInfo(team), team.color)
    end
end

function this.create(command)
    local owner = getPlayerById(command.player_index)
    local title = command.parameter

    --- Проверка, что название указано
    if title == nil then
        title = owner.name
    end

    --- Проверка, что состоит в команде по умолчанию
    if owner.force.index ~= teams.store.forces.getDefault().index then
        return owner.print({'teams:error.you-already-in-team'}, colors.red)
    end

    --- Проверка, что есть место для создания команды
    if getSize(teams.store.forces.getAll()) >= 61 then -- 61 - из доки
        return owner.print({'teams:error.reach-limit-forces'}, colors.red)
    end

    --- Проверка, что название команды не занято и имя для force свободно
    if teams.store.forces.get(title) ~= nil or teams.store.teams.getByTitle(title) ~= nil then
        return owner.print({'teams:error.title-already-used'}, colors.red)
    end

    local team = teams.base.create(title, owner)
    game.print({'teams:result.create', team.title}, team.color)
    owner.print({'mod.backstory'}, team.color)
end

function this.setName(command)
    local owner = getPlayerById(command.player_index)
    local team = teams.store.teams.getByName(owner.force.name)
    local oldTitle = team.title
    local newTitle = command.parameter

    --- Проверка, что это владелец команды
    if team.ownerId ~= owner.index then
        return owner.print({'teams:error.not-owner'}, colors.red)
    end

    --- Проверка, что новое название команды указано
    if newTitle == nil then
        return owner.print({'teams:error.title-not-specified'}, colors.red)
    end

    --- Проверка, что название команды не занято
    if teams.store.teams.getByTitle(newTitle) ~= nil then
        return owner.print({'teams:error.title-already-used'}, colors.red)
    end

    --- Редактируем и сообщаем всем об изменении
    team = teams.base.editTitle(team, newTitle)
    return game.print({'teams:result.edit-name', oldTitle, newTitle}, team.color)
end

function this.setColor(command)
    local owner = getPlayerById(command.player_index)
    local team = teams.store.teams.getByName(owner.force.name)

    --- Проверка, что это владелец команды
    if team.ownerId ~= owner.index then
        return owner.print({'teams:error.not-owner'}, colors.red)
    end

    --- Проверка, что цвет не тот же самый
    if isEqualRGBAColors(owner.color, team.color) then
        return owner.print({'teams:error.color-already-use'}, colors.red)
    end

    --- Редактируем и сообщаем всем об изменении
    local team = teams.base.editColor(team, owner.color)
    return game.print({'teams:result.edit-color', team.title}, team.color)
end

function this.inviteSend(command)
    local owner = getPlayerById(command.player_index)
    local team = teams.store.teams.getByName(owner.force.name)
    local player = getPlayerByName(command.parameter)

    --- Проверка, что это лидер команды
    if team.ownerId ~= owner.index then
        return owner.print({'teams:error.not-owner'}, colors.red)
    end

    --- Проверка, что ник указан
    if player == nil then
        return owner.print({'teams:error.player-not-found'}, colors.red)
    end

    --- Проверка, что нет команды
    if player.force.index ~= teams.store.forces.getDefault().index then
        return owner.print({'teams:error.player-already-in-team'}, colors.red)
    end

    local timeout = teams.config.invite.timeout.minutes

    --- Проверка, что приглашения у игрока на рассмотрении нет
    if teams.store.invites.get(player.index) ~= nil then
        return owner.print({'teams:error.already-have-invite', timeout}, colors.yellow)
    end

    teams.store.invites.set(owner.force.name, player.index)

    owner.print({'teams:event.invite-sended', player.name, timeout}, team.color)
    player.print({'teams:event.invite-getted', team.title, timeout}, team.color)
end

function this.inviteAccept(command)
    local player = getPlayerById(command.player_index)
    local invite = teams.store.invites.get(player.index)

    --- Проверка, что у нас есть приглашение
    if invite == nil then
        return player.print({'teams:error.not-have-invite'}, colors.yellow)
    end

    local forceName = invite.forceFromName
    teams.store.invites.remove(player.index)

    local force = teams.store.forces.get(forceName)
    teams.base.change(player, force)

    local team = teams.store.teams.getByName(forceName)
    game.print({'teams:event.invite-accepted', player.name, team.title}, team.color)
end

function this.inviteCancel(command)
    local player = getPlayerById(command.player_index)

    --- Проверка, что у нас есть приглашение для отклонения
    local invite = teams.store.invites.get(player.index)
    if invite == nil then
        return player.print({'teams:error.not-have-invite'}, colors.yellow)
    end

    local forceName = invite.forceFromName
    teams.store.invites.remove(player.index)

    local team = teams.store.teams.getByName(forceName)
    game.print({'teams:event.invite-canceled', player.name, team.title}, team.color)
end

function this.kick(command)
    local owner = getPlayerById(command.player_index)
    local player = getPlayerByName(command.parameter)
    local team = teams.store.teams.getByName(owner.force.name)

    --- Проверка, что это владелец команды
    if team.ownerId ~= owner.index then
        return owner.print({'teams:error.not-owner'}, colors.red)
    end

    --- Проверка, что это не лидер
    if owner == player then
        return owner.print({'teams:error.can-t-kick-owner'}, colors.red)
    end

    --- Проверка, что ник указан
    if player == nil then
        return owner.print({'teams:error.player-not-found'}, colors.red)
    end

    --- Проверка, что игрок в той же команде
    if owner.force.index ~= player.force.index then
        return owner.print({'teams:error.player-not-in-team'}, colors.red)
    end

    teams.base.kick(player)
    game.print({'teams:result.kick', player.name, team.title}, team.color)
end

function this.change(command)
    local owner = getPlayerById(command.player_index)

    --- Проверка, что это админ
    if owner.admin == false then
        return game.print({'errors.not-admin', owner.name, command.name})
    end

    --- Получение и проверка переданных параметров
    local params = getForceAndPlayerFromParameter(command.parameter)
    if params.force == nil then
        return owner.print({'teams:error.team-not-found'}, colors.red)
    end
    if params.player == nil then
        return owner.print({'teams:error.player-not-found'}, colors.red)
    end

    --- Проверка, что игрок ещё не состоит в команде
    if params.force.index == params.player.force.index then
        return owner.print({'teams:error.player-already-in-team'}, colors.red)
    end

    local team = teams.store.teams.getByName(params.player.force.name)
    local oldTitle = team.title

    --- Проверка, что это не лидер команды, иначе распустить её
    if team.ownerId == params.player.index then
        teams.base.remove(params.player.force.name)
    end

    teams.base.change(params.player, params.force)

    return game.print({'teams:result.change', params.player.name, oldTitle, params.team.title}, params.team.color)
end

function this.remove(command)
    local owner = getPlayerById(command.player_index)
    local team = teams.store.teams.getByName(owner.force.name)

    --- Проверка, что это владелец команды
    if team.ownerId ~= owner.index then
        return owner.print({'teams:error.not-owner'}, colors.red)
    end

    local oldTitle = team.title
    local oldColor = team.color

    teams.base.remove(team.name)

    game.print({'teams:result.remove', oldTitle}, oldColor)
end

function this.leave(command)
    local player = getPlayerById(command.player_index)
    local team = teams.store.teams.getByName(player.force.name)

    --- Проверка, что это не владелец команды
    if team.ownerId == player.index then
        return player.print({'teams:error.can-t-leave-owner'}, colors.red)
    end

    --- Проверка, что есть команда
    if team.id == teams.store.forces.getDefault().index then
        return player.print({'teams:error.not-have-team'}, colors.red)
    end

    local oldTitle = team.title
    local oldColor = team.color

    teams.base.leave(player)

    game.print({'teams:result.leave', player.name, oldTitle}, oldColor)
end

return this
