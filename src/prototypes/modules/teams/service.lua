--- Сервис управления командами в модуле.
--- Суть работы в том что дублирует информацию о force в
--- глобальное хранилище мода и синхронизирует их состояния.
TeamModuleService = {}

--- @public
--- Создаёт команду и соответственно ей force
--- Перемещает игрока в созданную команду.
--- @param teamName string | nil Если не указано, то выбросит ошибку
--- @param requesterId number
--- @return TeamEntity
function TeamModuleService.create(teamName, requesterId)
    local requester = PlayerUtils.getById(requesterId)

    --- Проверка, что есть место для создания команды
    if TableUtils.getSize(game.forces) >= 61 then -- 61 - из доки
        error({ ConfigService.getKey('teams.create-error-reach-limit-forces') })
    end

    if teamName == nil then
        error({ ConfigService.getKey('teams.error-team-title-required') })
    end

    --- Проверка, что название команды не занято и имя для force свободно
    if TeamModuleService.isNameAndTitleFree(teamName) == false then
        error({ ConfigService.getKey('teams.create-error-already-used'), teamName })
    end

    --- Если игрок владел командой, то удаляем её
    if requester.force.name ~= DEFAULT_TEAM_NAME then
        --- Игнорируем выброс ошибки на случай если это не владелец команды
        pcall(TeamModuleService.deleteByAdmin, TeamModuleService.getByName(requester.force.name).title, requester.index)
    end

    local forceCreated = game.create_force(teamName)
    --- @type TeamEntity
    local team = {
        id = forceCreated.index,
        ---Оригинальное имя, никогда не меняется
        name = forceCreated.name,
        ---Отображаемое имя, может меняться
        title = forceCreated.name,
        color = ColorUtils.convertColorToColor0(requester.color),
        ownerId = requester.index
    }
    forceCreated.custom_color = team.color
    TeamModuleService.getAll()[teamName] = team
    requester.force = team.name

    LoggerService.chat(
        {
            ConfigService.getKey('teams.create-result'),
            team.title,
            requester.name
        },
        team.color
    )

    return team
end

--- @public
--- Получить все команды (имитация базы данных).
--- Ключами таблицы являются имена команд.
--- @return table<string,TeamEntity>
function TeamModuleService.getAll()
    if global.teams == nil then
        --- Создаём объект хранения
        global.teams = {}
    end

    return global.teams
end

--- @private
--- Регистрирует все существующие команды (LuaForce -> TeamEnitity), которых нет в модуле.
--- Можно запускать сколько угодно раз.
function TeamModuleService.registerAll()
    local teams = TeamModuleService.getAll()

    for _, force in pairs(game.forces) do
        -- --- Такая команда есть в нашем модуле? Тогда пропускаем
        -- if teams[force.name] ~= nil then
        --     goto continue
        -- end

        --- @type TeamEntity
        teams[force.name] = {
            id = force.index,
            name = force.name,
            title = force.name,
            color = ColorUtils.convertColorToColor0(force.custom_color or force.color),
            ownerId = nil
        }

        --- Если это команда по умолчанию, то используем предзаготовленные нами настройки
        if force.name == 'player' then
            teams[force.name].title = { ConfigService.getKey('teams.general-player-title') }
            teams[force.name].color = ColorUtils.colors.grey
            force.custom_color = teams[force.name].color
            force.disable_research()
            goto continue
        elseif force.name == 'enemy' then
            teams[force.name].title = { ConfigService.getKey('teams.general-enemy-title') }
            teams[force.name].color = ColorUtils.colors.red
            force.custom_color = teams[force.name].color
            -- Не отключаем исследования, чтобы кусаки могли развиваться (или это не влияет?)
            goto continue
        elseif force.name == 'neutral' then
            teams[force.name].title = { ConfigService.getKey('teams.general-neutral-title') }
            teams[force.name].color = ColorUtils.colors.white
            force.custom_color = teams[force.name].color
            force.disable_research()
            goto continue
        end

        --- Первого игрока команды сделаем владельцем, если он существует
        local owner = force.players[1]
        if owner ~= nil then
            teams[force.name].ownerId = owner.index
        end

        ::continue::
    end
end

--- @public
--- Возвращает сущность команды по имени
--- - Выбросит ошибку, если не найдёт
--- @param teamName string
--- @return TeamEntity
function TeamModuleService.getByName(teamName)
    local team = TeamModuleService.getAll()[teamName]

    if team == nil then
        error({ ConfigService.getKey('teams.error-team-not-found'), teamName })
    end

    return team
end

--- @public
--- Возвращает сущность команды по названию.
--- - Выбросит ошибку, если не найдёт
--- - Для команд по умолчанию сравнит по имени.
--- - Менее эффективно чем получение по имени.
--- @param teamTitle string
--- @return TeamEntity
function TeamModuleService.getByTitle(teamTitle)
    for _, team in pairs(TeamModuleService.getAll()) do
        --- У команд по умолчанию вставлена строка локализации
        if type(team.title) == "table" then
            if team.name == teamTitle then return team end
        else
            if team.title == teamTitle then return team end
        end
    end

    error({ ConfigService.getKey('teams.error-team-not-found'), teamTitle })
end

--- @private
--- Проверяет свободно ли имя & название команды или занято
--- @param value string
--- @return boolean
function TeamModuleService.isNameAndTitleFree(value)
    for _, team in pairs(TeamModuleService.getAll()) do
        if team.name == value or team.title == value then
            return false
        end
    end

    return true
end

--- @public
--- Меняет название команды
--- @param requesterId number
--- @param teamTitleNew string | nil Если не указано, то выбросит ошибку
--- @return TeamEntity
function TeamModuleService.editTitle(requesterId, teamTitleNew)
    local requester = PlayerUtils.getById(requesterId)
    local team = TeamModuleService.getByName(requester.force.name)

    if team.ownerId ~= requester.index then
        error({ ConfigService.getKey('teams.error-team-not-owner') })
    end

    if teamTitleNew == nil then
        error({ ConfigService.getKey('teams.title-error-new-title-required') })
    end

    if teamTitleNew == team.title then
        error({ ConfigService.getKey('teams.title-error-equal-title') })
    end

    --- Проверка, что название команды не занято
    if TeamModuleService.isNameAndTitleFree(teamTitleNew) ~= nil then
        error({ ConfigService.getKey('teams.title-error-title-already-used'), teamTitleNew })
    end

    local teamTitleOld = team.title
    team.title = teamTitleNew
    LoggerService.chat({ ConfigService.getKey('teams.title-result'), teamTitleOld, teamTitleNew }, team.color)

    return team
end

--- @public
--- Меняет цвет команды
--- @param requesterId number
--- @param colorNew Color
--- @return TeamEntity
function TeamModuleService.editColor(requesterId, colorNew)
    colorNew = ColorUtils.convertColorToColor0(colorNew)

    local requester = PlayerUtils.getById(requesterId)
    local team = TeamModuleService.getByName(requester.force.name)

    --- Проверка, что это владелец команды
    if team.ownerId ~= requester.index then
        error({ ConfigService.getKey('teams.color.error-team-not-owner') })
    end

    --- Проверка, что цвет не тот же самый
    if ColorUtils.isEqualRGBAColors(colorNew, team.color) then
        error({ ConfigService.getKey('teams.color-error-equal-color') })
    end

    team.color = colorNew
    requester.force.custom_color = team.color

    LoggerService.chat({ ConfigService.getKey('teams.color-result') }, colorNew, requester.force)
    LoggerService.chat({ ConfigService.getKey('teams.color-general-info') }, nil, requester.force)

    return team
end

--- @public
--- Исключает игрока из команды
--- @param requesterId number
--- @param playerName string aka target
function TeamModuleService.kick(requesterId, playerName)
    local requester = PlayerUtils.getById(requesterId)
    local team = TeamModuleService.getByName(requester.force.name)

    if team.ownerId ~= requester.index then
        error({ ConfigService.getKey('teams.error-team-not-owner') })
    end

    if playerName == nil then
        error({ ConfigService.getKey('general.error-target-player-name-required') })
    end

    local player = PlayerUtils.getByName(playerName)

    if player.index == requester.index then
        error({ ConfigService.getKey('teams.kick-error-cant-kick-TeamModuleService') })
    end

    if requester.force.index ~= player.force.index then
        error({ ConfigService.getKey('teams.error-target-player-not-in-team') })
    end

    player.force = DEFAULT_TEAM_NAME

    return { team = team, player = player }
end

--- @public
--- Покидает команду от лица игрока
--- @param requesterId number
function TeamModuleService.leave(requesterId)
    local requester = PlayerUtils.getById(requesterId)
    local team = TeamModuleService.getByName(requester.force.name)

    if team.name == DEFAULT_TEAM_NAME then
        error({ ConfigService.getKey('teams.leave-error-cant-leave-default') })
    end

    if requester.index == team.ownerId then
        error({ ConfigService.getKey('teams.leave-error-owner-cant-leave') })
    end

    LoggerService.chat(
        {
            ConfigService.getKey('teams.leave-result'),
            requester.name,
            team.title
        },
        nil,
        requester
    )

    requester.force = DEFAULT_TEAM_NAME
end

--- @public
--- Пригласить игрока в свою команду
--- @param requesterId number
--- @param playerNickname string
--- @return OfferEntity
function TeamModuleService.invite(requesterId, playerNickname)
    local requester = PlayerUtils.getById(requesterId)
    local team = TeamModuleService.getByName(requester.force.name)

    if team.ownerId ~= requester.index then
        error({ ConfigService.getKey('teams.error-team-not-owner') })
    end

    if playerNickname == nil then
        error({ ConfigService.getKey('general.error-target-player-name-required') })
    end

    local player = PlayerUtils.getByName(playerNickname)

    if team.id == player.force.index then
        error({ ConfigService.getKey('teams.invite-error-player-already-in-team'), player.name, team.title })
    end

    -- @type number
    local timeoutMinutes = ConfigService.getValue('teams.invite-timeout')
    local offer = OfferModuleService.create({
        eventId = TEAM_INVITE_RESOLVE_EVENT_NAME,
        playerId = player.index,
        localisedMessage = { ConfigService.getKey('teams.invite-result-offer'), team.title },
        timeoutMinutes = timeoutMinutes,
        data = {
            teamName = team.name
        }
    })

    LoggerService.chat(
        {
            ConfigService.getKey('teams.invite-result-sender'),
            player.name,
            team.title,
            TimeUtils.minutesToClock(timeoutMinutes)
        },
        team.color,
        requester.force
    )

    return offer
end

--- @public
--- Удаляет команду из игры (постройки станут принадлежать команде по умолчанию)
--- @param requesterId number
function TeamModuleService.delete(requesterId)
    local requester = PlayerUtils.getById(requesterId)
    local team = TeamModuleService.getByName(requester.force.name)

    --- Проверка, что это владелец команды
    if team.ownerId ~= requester.index then
        error({ ConfigService.getKey('teams.error-team-not-owner') })
    end

    local teamTitle = team.title
    local teamColor = team.color

    --- Сливаем `force` в команду по умолчанию (так работает удаление в факторио)
    game.merge_forces(team.name, DEFAULT_TEAM_NAME)
    TeamModuleService.getAll()[team.name] = nil

    LoggerService.chat({ ConfigService.getKey('teams.delete-result'), teamTitle }, teamColor)
end

--- @public
--- Удаляет команду по названию от админа (если указан идентификатор)
--- @param teamTitle string
--- @param requesterId? number | nil
function TeamModuleService.deleteByAdmin(teamTitle, requesterId)
    if requesterId and PlayerUtils.getById(requesterId).admin == false then
        error({ ConfigService.getKey('general.error-not-admin') })
    end

    local team = TeamModuleService.getByTitle(teamTitle)
    if team.name == 'player' or team.name == 'enemy' or team.name == 'neutral' then
        error({ ConfigService.getKey('teams.delete-error-cant-delete-default'), team.name, team.title })
    end

    ---Сливаем `force` в команду по умолчанию
    game.merge_forces(team.name, DEFAULT_TEAM_NAME)
    TeamModuleService.getAll()[team.name] = nil

    LoggerService.chat({ ConfigService.getKey('teams.delete-result-by-admin'), team.title }, team.color)
end

--- @public
--- Меняет игроку команду (принудительно) от админа (если указан идентификатор).
--- Если игрока имеет свою команду, то она будет распущена.
--- @param teamTitleNew string
--- @param playerNickname string
--- @param requesterId? number | nil
--- @return { teamOld: TeamEntity, teamNew: TeamEntity }
function TeamModuleService.changeTeamOfPlayerByAdmin(teamTitleNew, playerNickname, requesterId)
    if requesterId and PlayerUtils.getById(requesterId).admin == false then
        error({ ConfigService.getKey('general.error-not-admin') })
    end

    local teamNew = TeamModuleService.getByTitle(teamTitleNew)

    local player = PlayerUtils.getByName(playerNickname)

    --- Проверка, что игрок ещё не состоит в целевой команде
    if teamNew.id == player.force.index then
        error({ ConfigService.getKey('teams.admin-change-error-target-player-already-in-team'), player.name,
            teamNew.title })
    end

    --- Если этот игрок владеет своей командой, то распустить её
    local teamOld = TeamModuleService.getByName(player.force.name)

    if teamOld.ownerId == player.index then
        local _title = teamOld.title
        assert(type(_title) == 'string')
        TeamModuleService.deleteByAdmin(_title, requesterId)
    end

    player.force = teamNew.name

    LoggerService.chat({ ConfigService.getKey('teams.admin-change-result'), player.name, teamNew.title })

    return { teamOld = teamOld, teamNew = teamNew }
end
