local function bootstrap()
    --- Если какой-либо консольной команды нет, значит и других нет
    if commands.commands['relations'] ~= nil then return end

    commands.add_command('relations', { 'mt.relations.list.help' },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local list = RelationModuleService.getAllFor(requester.force.name)
            local titles = { friends = {}, neutrals = {}, enemies = {} }
            local result = { friends = '', neutrals = '', enemies = '' }

            for key, value in pairs(list) do
                for _, team in pairs(value) do
                    table.insert(titles[key], team.title)
                end

                result[key] = table.concat(titles[key], ', ')
                if string.len(result[key]) == 0 then
                    result[key] = '-'
                end
            end

            LoggerService.chat({ 'mt.relations.list.result.header' }, nil, requester)
            LoggerService.chat({ 'mt.relations.list.result.friends', result.friends }, nil, requester)
            LoggerService.chat({ 'mt.relations.list.result.neutrals', result.neutrals }, nil, requester)
            LoggerService.chat({ 'mt.relations.list.result.enemies', result.enemies }, nil, requester)
        end)

    commands.add_command('relation-enemy', { 'mt.relations.set.enemy.help' },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)
            local teamDestinationTitle = command.parameter

            local status, result = pcall(
                RelationModuleService.setRelation,
                teamDestinationTitle,
                'enemy',
                requester.index
            )
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, requester)
            end
        end)

    commands.add_command('relation-neutral', { 'mt.relations.set.neutral.help' },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)
            local teamDestinationTitle = command.parameter

            local status, result = pcall(
                RelationModuleService.setRelation,
                teamDestinationTitle,
                'neutral',
                requester.index
            )
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, requester)
            end
        end)

    commands.add_command('relation-friend', { 'mt.relations.set.friend.help' },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)
            local teamDestinationTitle = command.parameter

            local status, result = pcall(
                RelationModuleService.setRelation,
                teamDestinationTitle,
                'friend',
                requester.index
            )
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, requester)
            end
        end)

    commands.add_command('friendly-fire', { 'mt.relations.friendly-fire.help' },
        function(command)
            local requester = PlayerUtils.getById(command.player_index)

            local status, result = pcall(
                RelationModuleService.switchFriendlyFire,
                requester.index
            )
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, requester)
            end
        end)
end

bootstrap()
