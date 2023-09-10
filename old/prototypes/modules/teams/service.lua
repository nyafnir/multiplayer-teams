---NOTE: важно различать team name (имя) и team title (название), название можно менять, а имя нет.
---NOTE: у игрока всегда есть команда, не может быть игрока без команды.

local this = {
    defaultForceName = 'player'
}
local admin = {}

local hasGlobal = false

---Создаёт MTTeam-s на основе LuaForce-s, если объекта команд нет в глобале.
---Возвращает объект команд.
function this.getTeams()
    if hasGlobal then
        return global.teams
    end

    if global.teams == nil then
        --- Создаём объект хранения
        global.teams = {}
    end

    ---Добавляем существующие команды
    for forceName, force in pairs(game.forces) do
        ---Такая команда есть в нашем модуле? Тогда пропускаем
        if global.teams[forceName] ~= nil then
            goto continue
        end

        global.teams[forceName] = {
            id = force.index,
            name = forceName,
            title = forceName,
            color = force.color,
            ownerId = nil
        }

        ---Меняем настройки команд по умолчанию
        if forceName == 'player' then
            global.teams[forceName].title = { configService.getKey('teams:common.team-player-title') }
            global.teams[forceName].color = colorService.list.white

            force.disable_research()

            goto continue
        elseif forceName == 'enemy' then
            global.teams[forceName].title = { configService.getKey('teams:common.team-enemy-title') }
            global.teams[forceName].color = colorService.list.red

            goto continue
        elseif forceName == 'neutral' then
            global.teams[forceName].title = { configService.getKey('teams:common.team-neutral-title') }
            global.teams[forceName].color = colorService.list.white

            force.disable_research()

            goto continue
        end

        ---Первого игрока команды сделаем владельцем, если он существует
        local owner = force.players[1]
        if owner ~= nil then
            global.teams[forceName].ownerId = owner.index
        end

        ::continue::
    end

    hasGlobal = true
    return this.getTeams()
end

---Создаёт `LuaForce` и `MTTeam`.
---Перемещает игрока в созданную команду.
---@param teamName string | nil
---@param requesterId number
---@param color Color | nil
---@return MTTeam
function this.create(teamName, requesterId, color)
    --- Проверка, что есть место для создания команды
    if Utils.table.getSize(game.forces) >= 61 then -- 61 - из доки
        error({ configService.getKey('teams:create.error-reach-limit-forces') })
    end

    if teamName == nil then
        error({ configService.getKey('teams:create.error-title-not-specified') })
    end

    --- Проверка, что название команды не занято и имя для force свободно
    if this.checkNameFree(teamName) == false then
        error({ configService.getKey('teams:create.error-title-already-used'), teamName })
    end

    local requester = playerService.getById(requesterId)
    local forceCurrent = requester.force

    ---Если игрок состоял в команде не по умолчанию, то удаляем её
    if forceCurrent.name ~= this.defaultForceName then
        ---Заглушаем выброс ошибки, если это не владелец команды
        pcall(this.admin.remove, this.getByName(forceCurrent.name).title, requester.index)
    end

    local forceNew = game.create_force(teamName)
    ---@type MTTeam
    local team = {
        id = forceNew.index,
        ---Оригинальное имя, никогда не меняется
        name = forceNew.name,
        ---Отображаемое имя, может меняться
        title = forceNew.name,
        color = color or requester.color,
        ownerId = requester.index
    }
    this.getTeams()[teamName] = team

    requester.force = team.name

    game.print({ configService.getKey('teams:create.result'), team.title, requester.name }, team.color)
    requester.print({ configService.getKey('teams:create.result-backstory') }, team.color)

    ---*Разрешено, поэтому код закомментирован
    ---Запрещаем нанесение урона между "Без команды" и новой командой
    -- local forceDefault = game.forces[this.defaultForceName]
    -- forceDefault.set_cease_fire(forceNew, true)
    -- forceNew.set_cease_fire(forceDefault, true)

    return team
end

---Удаляет `MTTeam` и `LuaForce`.
---@param requesterId number
function this.remove(requesterId)
    local requester = playerService.getById(requesterId)
    local force = requester.force

    ---@type MTTeam Здесь никогда не будет `nil`
    ---@diagnostic disable-next-line: assign-type-mismatch
    local team = this.getByName(force.name)

    --- Проверка, что это владелец команды
    if team.ownerId ~= requester.index then
        error({ configService.getKey('teams:remove.error-team-not-owner') })
    end

    ---Сливаем `force` в команду по умолчанию
    game.merge_forces(team.name, game.forces[this.defaultForceName].name)

    local teamTitle = team.title
    local teamColor = team.color

    ---Удаляем MTTeam
    this.getTeams()[team.name] = nil

    game.print({ configService.getKey('teams:remove.result'), teamTitle }, teamColor)
end

---@param teamName string
---@return MTTeam | nil
function this.getByName(teamName)
    return this.getTeams()[teamName]
end

---@param teamTitle string
---@return MTTeam | nil
function this.getByTitle(teamTitle)
    for _, team in pairs(this.getTeams()) do
        ---У команд по умолчанию вставлена строка локализации для названий
        if type(team.title) == "table" then
            ---Поэтому сравниваем их по имени
            if team.name == teamTitle then return team end
        else
            if team.title == teamTitle then return team end
        end
    end

    return nil
end

---Проверяет свободно ли имя и название (true) или занято (false)
---@param teamName string aka teamTitle
---@return boolean
function this.checkNameFree(teamName)
    for _, team in pairs(this.getTeams()) do
        if team.name == teamName
            or team.title == teamName
        then
            return false
        end
    end

    return true
end

---Меняет название команды.
---@param requesterId number
---@param teamTitleNew string
function this.changeTitle(requesterId, teamTitleNew)
    local requester = playerService.getById(requesterId)
    local force = requester.force

    ---@type MTTeam Здесь никогда не будет `nil`
    ---@diagnostic disable-next-line: assign-type-mismatch
    local team = this.getByName(force.name)

    if team.ownerId ~= requester.index then
        error({ configService.getKey('teams:title.error-team-not-owner') })
    end

    if teamTitleNew == nil then
        error({ configService.getKey('teams:title.error-new-title-not-specified') })
    end

    if teamTitleNew == team.title then
        error({ configService.getKey('teams:title.error-equal-title') })
    end

    --- Проверка, что название команды не занято
    if this.getByTitle(teamTitleNew) ~= nil then
        error({ configService.getKey('teams:title.error-title-already-used'), teamTitleNew })
    end

    local titleOld = team.title

    team.title = teamTitleNew

    game.print({ configService.getKey('teams:title.result'), titleOld, team.title }, team.color)
end

---@param colorNew Color
---@param requesterId number
function this.changeColor(colorNew, requesterId)
    local requester = playerService.getById(requesterId)
    local force = requester.force

    ---@type MTTeam Здесь никогда не будет `nil`
    ---@diagnostic disable-next-line: assign-type-mismatch
    local team = this.getByName(force.name)

    --- Проверка, что это владелец команды
    if team.ownerId ~= requester.index then
        error({ configService.getKey('teams:color.error-team-not-owner') })
    end

    --- Проверка, что цвет не тот же самый
    if colorService.isEqualRGBAColors(colorNew, team.color) then
        error({ configService.getKey('teams:color.error-equal-color') })
    end

    team.color = colorNew

    requester.print({ configService.getKey('teams:color.info-about-force-color') })
    game.print({ configService.getKey('teams:color.result'), team.title }, team.color)
end

---Исключить игрока из команды.
---@param playerNickname string
---@param requesterId number
function this.kick(playerNickname, requesterId)
    local requester = playerService.getById(requesterId)
    local force = requester.force

    ---@type MTTeam Здесь никогда не будет `nil`
    ---@diagnostic disable-next-line: assign-type-mismatch
    local team = this.getByName(force.name)

    if team.ownerId ~= requester.index then
        error({ configService.getKey('teams:kick.error-team-not-owner') })
    end

    if playerNickname == nil then
        error({ configService.getKey('teams:kick.error-player-not-specified') })
    end

    local player = playerService.getByName(playerNickname)
    if player == nil then
        error({ configService.getKey('teams:kick.error-player-not-founded'), playerNickname })
    end

    if player.index == requester.index then
        error({ configService.getKey('teams:kick.error-cant-kick-self') })
    end

    if requester.force.index ~= player.force.index then
        error({ configService.getKey('teams:kick.error-player-not-in-team') })
    end

    player.force = this.defaultForceName

    game.print({ configService.getKey('teams:kick.result'), player.name, team.title }, team.color)
end

---@param requesterId number
function this.leave(requesterId)
    local requester = playerService.getById(requesterId)
    local force = requester.force

    if force.name == this.defaultForceName then
        error({ configService.getKey('teams:leave.error-cant-leave-default') })
    end

    ---@type MTTeam Здесь никогда не будет `nil`
    ---@diagnostic disable-next-line: assign-type-mismatch
    local team = this.getByName(force.name)

    if requester.index == team.ownerId then
        error({ configService.getKey('teams:leave.error-owner-cant-leave') })
    end

    requester.force = this.defaultForceName

    game.print({ configService.getKey('teams:leave.result'), requester.name, team.title }, team.color)
end

---Удаляет команду по названию без проверки на владельца.
---@param teamTitle string
---@param requesterId number | nil
function admin.remove(teamTitle, requesterId)
    local requester = { admin = true }
    ---Игнорируем проверку на админа, если nil
    if requesterId ~= nil then
        requester = playerService.getById(requesterId)
    end

    if requester.admin == false then
        error({ configService.getKey('teams:admin:remove.error-not-admin') })
    end

    if teamTitle == nil then
        error({ configService.getKey('teams:admin:remove.error-team-not-specified') })
    end

    local team = this.getByTitle(teamTitle)
    if team == nil then
        error({ configService.getKey('teams:admin:remove.error-team-not-founded'), teamTitle })
    end

    if team.name == 'player'
        or
        team.name == 'enemy'
        or
        team.name == 'neutral'
    then
        error({ configService.getKey('teams:admin:remove.error-cant-remove-default'), team.name })
    end

    local teamName = team.name
    local teamColor = team.color

    ---Удаляем MTTeam
    this.getTeams()[team.name] = nil

    ---Сливаем `force` в команду по умолчанию
    game.merge_forces(teamName, game.forces[this.defaultForceName].name)

    game.print({ configService.getKey('teams:admin:remove.result'), teamTitle }, teamColor)
end

---Меняет игроку команду принудительно.
---@param teamTitleNew string
---@param playerNickname string
---@param requesterId number | nil
function admin.changeTeamOfPlayer(teamTitleNew, playerNickname, requesterId)
    local requester = { admin = true }
    ---Игнорируем проверку на админа, если nil
    if requesterId ~= nil then
        requester = playerService.getById(requesterId)
    end

    if requester.admin == false then
        error({ configService.getKey('teams:admin:change.error-not-admin') })
    end

    local teamNew = this.getByTitle(teamTitleNew)
    if teamNew == nil then
        error({ configService.getKey('teams:admin:change.error-team-not-founded'), teamTitleNew })
    end

    local player = playerService.getByName(playerNickname)
    if player == nil then
        error({ configService.getKey('teams:admin:change.error-player-not-founded') })
    end

    ---Проверка, что игрок ещё не состоит в целевой команде
    if teamNew.id == player.force.index then
        error({ configService.getKey('teams:admin:change.error-player-already-in-team'), player.name, teamNew.title })
    end

    --- Если лидер команды, то распустить её
    ---@type MTTeam Здесь никогда не будет `nil`
    ---@diagnostic disable-next-line: assign-type-mismatch
    local teamOld = this.getByName(player.force.name)
    if teamOld.ownerId == player.index then
        this.admin.remove(teamOld.title, requesterId)
    end

    player.force = teamNew.name

    game.print({ configService.getKey('teams:admin:change.result'), player.name, teamNew.title }, teamNew.color)
end

---Пригласить игрока в свою команду.
---@param playerNickname string
---@param requesterId number
function this.sendInvite(playerNickname, requesterId)
    local requester = playerService.getById(requesterId)
    local force = requester.force

    ---@type MTTeam Здесь никогда не будет `nil`
    ---@diagnostic disable-next-line: assign-type-mismatch
    local team = this.getByName(force.name)

    if team.ownerId ~= requester.index then
        error({ configService.getKey('teams:invite.error-team-not-owner') })
    end

    if playerNickname == nil then
        error({ configService.getKey('teams:invite.error-player-not-specified') })
    end

    local player = playerService.getByName(playerNickname)
    if player == nil then
        error({ configService.getKey('teams:invite.error-player-not-founded') })
    end

    if team.id == player.force.index then
        error({ configService.getKey('teams:invite.error-player-already-in-team'), player.name, team.title })
    end

    ---@type MTOfferInput
    local offerInput = {
        eventId = teamModule.events.onMTTeamInviteResolve,
        playerId = player.index,
        localisedMessage = { configService.getKey('teams:invite.result-recipient'), team.title },
        timeoutMinutes = configService.get('teams:invite-timeout'),
        data = {
            teamName = team.name
        }
    }

    offerModule.service.create(offerInput)

    requester.force.print({ configService.getKey('teams:invite.result-sender'), player.name, team.title,
        Utils.time.minutesToClock(offerInput.timeoutMinutes) },
        team.color)
end

this.admin = admin
return this
