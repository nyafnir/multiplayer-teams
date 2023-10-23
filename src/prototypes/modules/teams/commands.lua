local function bootstrap()
    --- Если какой-либо консольной команды нет, значит и других нет
    if commands.commands['teams'] ~= nil then return end

    commands.add_command('team-create', { ConfigService.getKey('teams.create-help') },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result = pcall(TeamModuleService.create, command.parameter, requester.index)
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, requester)
            end
            local team = result

            LoggerService.chat(
                {
                    ConfigService.getKey('teams.create-backstory')
                },
                team.color,
                requester
            )
        end)

    commands.add_command('team-info', { ConfigService.getKey('teams.info-help') }, function(command)
        local requester = PlayerUtils.getById(command.player_index)

        local team
        -- Если запрос инфы по своей команде (вызов без параметров)
        if command.parameter == nil or command.parameter == '' then
            team = TeamModuleService.getByName(requester.force.name)
        else
            team = TeamModuleService.getByTitle(command.parameter)
        end

        local countPlayers = TableUtils.getSize(requester.force.players)
        --- @type table | string
        local ownerName = { ConfigService.getKey('teams.general-no-owner') }
        if team.ownerId ~= nil then
            ownerName = PlayerUtils.getById(team.ownerId).name
        end

        LoggerService.chat(
            {
                ConfigService.getKey('teams.info-result-header'),
                team.name
            },
            team.color,
            requester
        )
        LoggerService.chat(
            {
                ConfigService.getKey('teams.info-result-element'),
                team.id,
                team.title,
                ownerName,
                countPlayers,
                team.name
            },
            team.color,
            requester
        )
    end)

    commands.add_command('team-list', { ConfigService.getKey('teams.list-help') }, function(command)
        local requester = PlayerUtils.getById(command.player_index)

        LoggerService.chat({ ConfigService.getKey('teams.list-result-header') }, ColorUtils.colors.white, requester)

        for _, team in pairs(TeamModuleService.getAll()) do
            local force = game.forces[team.name]

            local countPlayers = TableUtils.getSize(force.players)
            --- Прячем пустые команды
            if countPlayers == 0 then
                goto continue
            end

            --- @type table | string
            local ownerName = { ConfigService.getKey('teams.general-no-owner') }
            if team.ownerId ~= nil then
                ownerName = PlayerUtils.getById(team.ownerId).name
            end

            LoggerService.chat(
                {
                    ConfigService.getKey('teams.list-result-element'),
                    team.id,
                    team.title,
                    ownerName,
                    countPlayers,
                    team.name
                },
                team.color,
                requester
            )

            ::continue::
        end
    end)

    commands.add_command('team-players', { ConfigService.getKey('teams.players-help') },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local team
            -- Если запрос инфы по своей команде (вызов без параметров)
            if command.parameter == nil or command.parameter == '' then
                team = TeamModuleService.getByName(requester.force.name)
            else
                team = TeamModuleService.getByTitle(command.parameter)
            end

            local force = game.forces[team.name]

            LoggerService.chat(
                {
                    ConfigService.getKey('teams.players-result-header'),
                    team.name
                },
                team.color,
                requester
            )
            for _, member in pairs(force.players) do
                LoggerService.chat(
                    {
                        ConfigService.getKey('teams.players-result-element'),
                        member.index,
                        member.name
                    },
                    member.color,
                    requester
                )
            end
        end)

    commands.add_command('team-delete', { ConfigService.getKey('teams.delete-help') },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result
            if command.parameter == nil then
                status, result = pcall(TeamModuleService.delete, requester.index)
            else
                status, result = pcall(TeamModuleService.deleteByAdmin,
                    command.parameter, requester.index)
            end

            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, requester)
            end
        end)

    commands.add_command('team-title', { ConfigService.getKey('teams.title-help') },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result = pcall(TeamModuleService.editTitle, requester.index,
                command.parameter)
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, requester)
            end
        end)

    commands.add_command('team-color', { ConfigService.getKey('teams.color-help') },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result = pcall(TeamModuleService.editColor, requester.index,
                requester.color)
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, requester)
            end
        end)

    commands.add_command('team-kick', { ConfigService.getKey('teams.kick-help') }, function(command)
        local requester = PlayerUtils.getById(command.player_index)

        local status, result = pcall(TeamModuleService.kick, requester.index, command.parameter)
        if status == false then
            return LoggerService.chat(result, ColorUtils.colors.red, requester)
        end

        LoggerService.chat(
            {
                ConfigService.getKey('teams.kick-result'),
                result.player.name,
                result.team.title
            },
            result.team.color,
            requester
        )
    end)

    commands.add_command('team-leave', { ConfigService.getKey('teams.leave-help') },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result = pcall(TeamModuleService.leave, requester.index, command.parameter)
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, requester)
            end
        end)

    commands.add_command('team-invite', { ConfigService.getKey('teams.invite-help') },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result = pcall(TeamModuleService.invite, requester.index, command.parameter)
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red.requester)
            end
        end)

    commands.add_command('team-change-admin', { ConfigService.getKey('teams.admin-change-help') },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            --- Все до последнего слова - название команды
            local _, _, teamTitleNew, playerNickname = string.find(command.parameter or '', "([%s%S]*) ([%S]*)$")

            local status, result = pcall(TeamModuleService.changeTeamOfPlayerByAdmin, teamTitleNew or '',
                playerNickname or '', requester.index)
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, requester)
            end
        end)
end

bootstrap()
