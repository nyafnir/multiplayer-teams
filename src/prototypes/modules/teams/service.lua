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
function TeamModuleService:create(teamName, requesterId)
    local requester = PlayerUtils.getById(requesterId)

    --- Проверка, что есть место для создания команды
    if TableUtils.getSize(game.forces) >= 61 then -- 61 - из доки
        error({ ConfigService.getKey('teams.create-error-reach-limit-forces') })
    end

    if teamName == nil then
        error({ ConfigService.getKey('teams.create-error-title-required') })
    end

    --- Проверка, что название команды не занято и имя для force свободно
    if self:isNameAndTitleFree(teamName) == false then
        error({ ConfigService.getKey('teams.error-already-used'), teamName })
    end

    --- Если игрок владел командой, то удаляем её
    if requester.force.name ~= DEFAULT_TEAM_NAME then
        --- Игнорируем выброс ошибки на случай если это не владелец команды
        pcall(self.deleteByAdmin, self:getByName(requester.force.name).title, requester.index)
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
    self:getAll()[teamName] = team
    requester.force = team.name

    game.print(
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
function TeamModuleService:getAll()
    if global.teams == nil then
        --- Создаём объект хранения
        global.teams = {}
    end

    return global.teams
end

--- @private
--- Регистрирует все существующие команды (LuaForce -> TeamEnitity), которых нет в модуле.
--- Можно запускать сколько угодно раз.
function TeamModuleService:registerAll()
    local teams = self:getAll()

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
            teams[force.name].title = { ConfigService.getKey('teams.common-player-title') }
            teams[force.name].color = ColorUtils.colors.grey
            force.custom_color = teams[force.name].color
            force.disable_research()
            goto continue
        elseif force.name == 'enemy' then
            teams[force.name].title = { ConfigService.getKey('teams.common-enemy-title') }
            teams[force.name].color = ColorUtils.colors.red
            force.custom_color = teams[force.name].color
            -- Не отключаем исследования, чтобы кусаки могли развиваться (или это не влияет?)
            goto continue
        elseif force.name == 'neutral' then
            teams[force.name].title = { ConfigService.getKey('teams.common-neutral-title') }
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
--- @param teamName string
--- @return TeamEntity | nil
function TeamModuleService:getByName(teamName)
    return self:getAll()[teamName]
end

--- @public
--- Возвращает сущность команды по названию.
--- Не работает для команд по умолчанию.
--- Менее эффективно чем получение по имени.
--- @param teamTitle string
--- @return TeamEntity | nil
function TeamModuleService:getByTitle(teamTitle)
    for _, team in pairs(self:getAll()) do
        --- У команд по умолчанию вставлена строка локализации для
        --- названий и мы просто игнорируем такие названия
        if type(team.title) ~= "table" then
            if team.title == teamTitle then return team end
        end
    end

    return nil
end

--- @private
--- Проверяет свободно ли имя & название команды или занято
--- @param value string
--- @return boolean
function TeamModuleService:isNameAndTitleFree(value)
    for _, team in pairs(self:getAll()) do
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
function TeamModuleService:editTitle(requesterId, teamTitleNew)
    local requester = PlayerUtils.getById(requesterId)
    local team = self:getByName(requester.force.name)

    if team == nil then
        error({ ConfigService.getKey('teams.error-team-not-found') })
    end

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
    if self:isNameAndTitleFree(teamTitleNew) ~= nil then
        error({ ConfigService.getKey('teams.title-error-title-already-used'), teamTitleNew })
    end

    local teamTitleOld = team.title
    team.title = teamTitleNew
    game.print({ ConfigService.getKey('teams.title-result'), teamTitleOld, teamTitleNew }, team.color)

    return team
end

--- @public
--- Меняет цвет команды
--- @param requesterId number
--- @param colorNew Color
--- @return TeamEntity
function TeamModuleService:editColor(requesterId, colorNew)
    colorNew = ColorUtils.convertColorToColor0(colorNew)

    local requester = PlayerUtils.getById(requesterId)
    local team = self:getByName(requester.force.name)

    if team == nil then
        error({ ConfigService.getKey('teams.error-team-not-found') })
    end

    --- Проверка, что это владелец команды
    if team.ownerId ~= requester.index then
        error({ ConfigService.getKey('teams.color.error-team-not-owner') })
    end

    --- Проверка, что цвет не тот же самый
    if ColorUtils.isEqualRGBAColors(colorNew, team.color) then
        error({ ConfigService.getKey('teams.error-equal') })
    end

    team.color = colorNew
    requester.force.custom_color = team.color

    requester.print({ ConfigService.getKey('teams.color-general-info') })

    return team
end

--- @public
--- Исключает игрока из команды
--- @param requesterId number
--- @param playerName string aka target
function TeamModuleService:kick(requesterId, playerName)
    local requester = PlayerUtils.getById(requesterId)
    local team = self:getByName(requester.force.name)

    if team == nil then
        error({ ConfigService.getKey('teams.error-team-not-found') })
    end

    if team.ownerId ~= requester.index then
        error({ ConfigService.getKey('teams.error-team-not-owner') })
    end

    if playerName == nil then
        error({ ConfigService.getKey('teams.error-target-player-name-required') })
    end

    local player = PlayerUtils.getByName(playerName)
    if player == nil then
        error({ ConfigService.getKey('teams.error-target-player-not-found'), playerName })
    end

    if player.index == requester.index then
        error({ ConfigService.getKey('teams.kick-error-cant-kick-self') })
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
function TeamModuleService:leave(requesterId)
    local requester = PlayerUtils.getById(requesterId)
    local team = self:getByName(requester.force.name)

    if team == nil then
        error({ ConfigService.getKey('teams.error-team-not-found') })
    end

    if team.name == DEFAULT_TEAM_NAME then
        error({ ConfigService.getKey('teams.leave-error-cant-leave-default') })
    end

    if requester.index == team.ownerId then
        error({ ConfigService.getKey('teams.leave-error-owner-cant-leave') })
    end

    requester.print(
        {
            ConfigService.getKey('teams.leave-result'),
            requester.name,
            team.title
        }
    )

    requester.force = DEFAULT_TEAM_NAME
end

--- @public
--- Пригласить игрока в свою команду
--- @param requesterId number
--- @param playerNickname string
--- @return OfferEntity
function TeamModuleService:invite(requesterId, playerNickname)
    local requester = PlayerUtils.getById(requesterId)
    local team = self:getByName(requester.force.name)

    if team == nil then
        error({ ConfigService.getKey('teams.error-team-not-found') })
    end

    if team.ownerId ~= requester.index then
        error({ ConfigService.getKey('teams.error-team-not-owner') })
    end

    if playerNickname == nil then
        error({ ConfigService.getKey('teams.error-target-player-name-required') })
    end

    local player = PlayerUtils.getByName(playerNickname)
    if player == nil then
        error({ ConfigService.getKey('teams.error-target-player-not-found') })
    end

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

    requester.force.print(
        {
            ConfigService.getKey('teams.invite-result-sender'),
            player.name,
            team.title,
            TimeUtils.minutesToClock(timeoutMinutes)
        },
        team.color
    )

    return offer
end

--- @public
--- Удаляет команду из игры (постройки станут принадлежать команде по умолчанию)
--- @param requesterId number
function TeamModuleService:delete(requesterId)
    local requester = PlayerUtils.getById(requesterId)
    local team = self:getByName(requester.force.name)

    if team == nil then
        error({ ConfigService.getKey('teams.error-team-not-found') })
    end

    --- Проверка, что это владелец команды
    if team.ownerId ~= requester.index then
        error({ ConfigService.getKey('teams.error-team-not-owner') })
    end

    local teamTitle = team.title
    local teamColor = team.color

    --- Сливаем `force` в команду по умолчанию (так работает удаление в факторио)
    game.merge_forces(team.name, DEFAULT_TEAM_NAME)
    self:getAll()[team.name] = nil

    game.print({ ConfigService.getKey('teams.delete-result'), teamTitle }, teamColor)
end

--- @public
--- Удаляет команду по названию от админа (если указан идентификатор)
--- @param teamTitle string
--- @param requesterId? number | nil
function TeamModuleService:deleteByAdmin(teamTitle, requesterId)
    if requesterId and PlayerUtils.getById(requesterId).admin == false then
        error({ ConfigService.getKey('teams.error-not-admin') })
    end

    if teamTitle == nil then
        error({ ConfigService.getKey('teams.error-team-title-required') })
    end

    local team = self:getByTitle(teamTitle)
    if team == nil then
        error({ ConfigService.getKey('teams.error-team-not-found'), teamTitle })
    end

    if team.name == 'player' or team.name == 'enemy' or team.name == 'neutral' then
        error({ ConfigService.getKey('teams.delete-error-cant-delete-default'), team.name })
    end

    ---Сливаем `force` в команду по умолчанию
    game.merge_forces(team.name, DEFAULT_TEAM_NAME)
    self:getAll()[team.name] = nil

    game.print({ ConfigService.getKey('teams.admin-delete-result'), team.title })
end

--- @public
--- Меняет игроку команду (принудительно) от админа (если указан идентификатор).
--- Если игрока имеет свою команду, то она будет распущена.
--- @param teamTitleNew string
--- @param playerNickname string
--- @param requesterId? number | nil
--- @return { teamOld: TeamEntity, teamNew: TeamEntity }
function TeamModuleService:changeTeamOfPlayerByAdmin(teamTitleNew, playerNickname, requesterId)
    if requesterId and PlayerUtils.getById(requesterId).admin == false then
        error({ ConfigService.getKey('teams.error-not-admin') })
    end

    local teamNew = self:getByTitle(teamTitleNew)
    if teamNew == nil then
        error({ ConfigService.getKey('teams.error-team-not-found'), teamTitleNew })
    end

    local player = PlayerUtils.getByName(playerNickname)
    if player == nil then
        error({ ConfigService.getKey('teams.error-target-player-not-found') })
    end

    --- Проверка, что игрок ещё не состоит в целевой команде
    if teamNew.id == player.force.index then
        error({ ConfigService.getKey('teams.error-target-player-already-in-team'), player.name, teamNew.title })
    end

    --- Если этот игрок владеет своей командой, то распустить её
    local teamOld = self:getByName(player.force.name)

    if teamOld == nil then
        error({ ConfigService.getKey('teams.error-team-not-found') })
    end

    if teamOld.ownerId == player.index then
        local _title = teamOld.title
        assert(type(_title) == 'string')
        self:deleteByAdmin(_title, requesterId)
    end

    player.force = teamNew.name

    game.print({ ConfigService.getKey('teams.admin-change-result'), player.name, teamNew.title })

    return { teamOld = teamOld, teamNew = teamNew }
end
