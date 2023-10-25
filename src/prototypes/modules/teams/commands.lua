local function bootstrap()
    --- Если какой-либо консольной команды нет, значит и других нет
    if commands.commands['teams'] ~= nil then return end

    commands.add_command('team-create', { 'mt.teams.create.help' },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result = pcall(TeamModuleService.create, command.parameter, requester.index)
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, requester)
            end

            LoggerService.chat(
                {
                    'mt.teams.create.backstory'
                },
                nil,
                requester
            )
        end)

    commands.add_command('team-info', { 'mt.teams.info.help' }, function(command)
        local requester = PlayerUtils.getById(command.player_index)

        local status, result
        -- Если запрос инфы по своей команде (вызов без параметров)
        if command.parameter == nil or command.parameter == '' then
            status, result = pcall(TeamModuleService.getByName, requester.force.name)
        else
            status, result = pcall(TeamModuleService.getByTitle, command.parameter)
        end
        if status == false then
            return LoggerService.chat(result, ColorUtils.colors.red, requester)
        end
        local team = result

        local countPlayers = TableUtils.getSize(requester.force.players)
        --- @type table | string
        local ownerName = { 'mt.teams.general-owner-none' }
        if team.ownerId ~= nil then
            ownerName = PlayerUtils.getById(team.ownerId).name
        end

        LoggerService.chat(
            {
                'mt.teams.info.result.header',
                team.name
            },
            nil,
            requester
        )
        LoggerService.chat(
            {
                'mt.teams.info.result.element',
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

    commands.add_command('team-list', { 'mt.teams.list.help' }, function(command)
        local requester = PlayerUtils.getById(command.player_index)

        LoggerService.chat({ 'mt.teams.list.result.header' }, nil, requester)

        for _, team in pairs(TeamModuleService.getAll()) do
            local force = game.forces[team.name]

            local countPlayers = TableUtils.getSize(force.players)
            --- Прячем пустые команды
            if countPlayers == 0 then
                goto continue
            end

            --- @type table | string
            local ownerName = { 'mt.teams.general-owner-none' }
            if team.ownerId ~= nil then
                ownerName = PlayerUtils.getById(team.ownerId).name
            end

            LoggerService.chat(
                {
                    'mt.teams.list.result.element',
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

    commands.add_command('team-players', { 'mt.teams.players.help' },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result
            -- Если запрос инфы по своей команде (вызов без параметров)
            if command.parameter == nil or command.parameter == '' then
                status, result = pcall(TeamModuleService.getByName, requester.force.name)
            else
                status, result = pcall(TeamModuleService.getByTitle, command.parameter)
            end
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, requester)
            end
            local team = result

            local force = game.forces[team.name]

            LoggerService.chat(
                {
                    'mt.teams.players.result.header',
                    team.name
                },
                team.color,
                requester
            )
            for _, member in pairs(force.players) do
                LoggerService.chat(
                    {
                        'mt.teams.players.result.element',
                        member.index,
                        member.name
                    },
                    member.color,
                    requester
                )
            end
        end)

    commands.add_command('team-delete', { 'mt.teams.delete.help' },
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

    commands.add_command('team-title', { 'mt.teams.title.help' },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result = pcall(TeamModuleService.editTitle, requester.index,
                command.parameter)
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, requester)
            end
        end)

    commands.add_command('team-color', { 'mt.teams.color.help' },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result = pcall(TeamModuleService.editColor, requester.index,
                requester.color)
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, requester)
            end
        end)

    commands.add_command('team-kick', { 'mt.teams.kick.help' }, function(command)
        local requester = PlayerUtils.getById(command.player_index)

        local status, result = pcall(TeamModuleService.kick, requester.index, command.parameter)
        if status == false then
            return LoggerService.chat(result, ColorUtils.colors.red, requester)
        end
    end)

    commands.add_command('team-leave', { 'mt.teams.leave.help' },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result = pcall(TeamModuleService.leave, requester.index, command.parameter)
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, requester)
            end
        end)

    commands.add_command('team-invite', { 'mt.teams.invite.help' },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result = pcall(TeamModuleService.invite, requester.index, command.parameter)
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, requester)
            end
        end)

    commands.add_command('team-change-admin', { 'mt.teams.admin.change.help' },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            --- Все до последнего слова - название команды
            local _, _, teamTitleNew, playerNickname = string.find(command.parameter or '', "([%s%S]*) ([%S]*)$")

            local status, result = pcall(TeamModuleService.changeTeamOfPlayerByAdmin, teamTitleNew or '',
                playerNickname or '', requester.index)
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, requester)
            end

            LoggerService.chat({ 'mt.teams.admin.change.result', result.player.name, result.teamOld.title,
                result.teamNew.title }, result.teamNew.color)
        end)
end

bootstrap()
