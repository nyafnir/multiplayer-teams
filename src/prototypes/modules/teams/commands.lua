local function bootstrap()
    --- Если какой-либо консольной команды нет, значит и других нет
    if commands.commands['teams'] ~= nil then return end

    commands.add_command('team-create', { ConfigService.getKey('teams.create-help') },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result = pcall(TeamModuleService.create, command.parameter, requester.index, requester.color)
            if status == false then
                return requester.print(result, ColorUtils.colors.red)
            end
            local team = result

            requester.print(
                {
                    ConfigService.getKey('teams.create-backstory')
                },
                team.color
            )
        end)

    commands.add_command('team-info', { ConfigService.getKey('teams.info-help') }, function(command)
        local requester = PlayerUtils.getById(command.player_index)

        local team
        -- Если запрос инфы по своей команде (вызов без параметров)
        if command.parameter == nil or command.parameter == '' then
            team = TeamModuleService:getByName(requester.force.name)
        else
            team = TeamModuleService:getByTitle(command.parameter)
        end

        if team == nil then
            return requester.print(
                {
                    ConfigService.getKey('teams.error-team-not-found'),
                    command.parameter
                },
                ColorUtils.colors.yellow
            )
        end

        local countPlayers = TableUtils.getSize(requester.force.players)
        --- @type table | string
        local ownerName = { ConfigService.getKey('teams.common-no-owner') }
        if team.ownerId ~= nil then
            ownerName = PlayerUtils.getById(team.ownerId).name
        end

        requester.print(
            {
                ConfigService.getKey('teams.info-result-header'),
                team.name
            },
            team.color
        )
        requester.print(
            {
                ConfigService.getKey('teams.info-result-element'),
                team.id,
                team.title,
                ownerName,
                countPlayers
            },
            team.color
        )
    end)

    commands.add_command('team-list', { ConfigService.getKey('teams.list-help') }, function(command)
        local requester = PlayerUtils.getById(command.player_index)

        requester.print({ ConfigService.getKey('teams.list-result-header') }, ColorUtils.colors.white)

        for _, team in pairs(TeamModuleService:getAll()) do
            local force = game.forces[team.name]

            local countPlayers = TableUtils.getSize(force.players)
            --- Прячем пустые команды
            if countPlayers == 0 then
                goto continue
            end

            --- @type table | string
            local ownerName = { ConfigService.getKey('teams.common-no-owner') }
            if team.ownerId ~= nil then
                ownerName = PlayerUtils.getById(team.ownerId).name
            end

            requester.print(
                {
                    ConfigService.getKey('teams.list-result-element'),
                    team.id,
                    team.title,
                    ownerName,
                    countPlayers
                },
                team.color
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
                team = TeamModuleService:getByName(requester.force.name)
            else
                team = TeamModuleService:getByTitle(command.parameter)
            end

            if team == nil then
                return requester.print(
                    {
                        ConfigService.getKey('teams.error-team-not-found'),
                        command.parameter
                    },
                    ColorUtils.colors.yellow
                )
            end

            local force = game.forces[team.name]

            requester.print(
                {
                    ConfigService.getKey('teams.players-result-header'),
                    team.name
                },
                ColorUtils.colors.white
            )
            for _, member in pairs(force.players) do
                requester.print(
                    {
                        ConfigService.getKey('teams.players-result-element'),
                        member.index,
                        member.name
                    },
                    member.color
                )
            end
        end)

    commands.add_command('team-delete', { ConfigService.getKey('teams.delete-help') },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result = pcall(TeamModuleService.delete, requester.index)
            if status == false then
                return requester.print(result, ColorUtils.colors.red)
            end
        end)

    commands.add_command('team-title', { ConfigService.getKey('teams.title-help') },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result = pcall(TeamModuleService.editTitle, requester.index, command.parameter)
            if status == false then
                return requester.print(result, ColorUtils.colors.red)
            end
        end)

    commands.add_command('team-color', { ConfigService.getKey('teams.color-help') },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result = pcall(TeamModuleService.editColor, requester.index, command.parameter)
            if status == false then
                return requester.print(result, ColorUtils.colors.red)
            end

            requester.print({ ConfigService.getKey('teams.result'), result.color })
        end)

    commands.add_command('team-kick', { ConfigService.getKey('teams.kick-help') }, function(command)
        local requester = PlayerUtils.getById(command.player_index)

        local status, result = pcall(TeamModuleService.kick, requester.index, command.parameter)
        if status == false then
            return requester.print(result, ColorUtils.colors.red)
        end

        requester.print(
            {
                ConfigService.getKey('teams.kick-result'),
                result.player.name,
                result.team.title
            },
            result.team.color
        )
    end)

    commands.add_command('team-leave', { ConfigService.getKey('teams.leave-help') },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result = pcall(TeamModuleService.leave, requester.index, command.parameter)
            if status == false then
                return requester.print(result, ColorUtils.colors.red)
            end
        end)

    commands.add_command('team-invite', { ConfigService.getKey('teams.invite-help') },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result = pcall(TeamModuleService.invite, requester.index, command.parameter)
            if status == false then
                return requester.print(result, ColorUtils.colors.red)
            end
        end)

    commands.add_command('team-admin-delete', { ConfigService.getKey('teams.admin-delete-help') },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result = pcall(TeamModuleService.deleteByAdmin, requester.index, command.parameter)
            if status == false then
                return requester.print(result, ColorUtils.colors.red)
            end
        end)

    commands.add_command('team-admin-change', { ConfigService.getKey('teams.admin-change-help') },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result = pcall(TeamModuleService.changeTeamOfPlayerByAdmin, requester.index, command.parameter)
            if status == false then
                return requester.print(result, ColorUtils.colors.red)
            end
        end)
end

bootstrap()
