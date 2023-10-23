local function bootstrap()
    --- Если какой-либо консольной команды нет, значит и других нет
    if commands.commands['offers'] ~= nil then return end

    commands.add_command('offers', { ConfigService.getKey('offers.list-help') },
        function(command)
            local player = PlayerUtils.getById(command.player_index)

            local status, result = pcall(OfferModuleService.getAllByPlayer, player.index)
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, player)
            end

            LoggerService.chat({ ConfigService.getKey('offers.list-header') }, player.color, player)

            if TableUtils.getSize(result) == 0 then
                return LoggerService.chat({
                        ConfigService.getKey('offers.list-empty') },
                    player.color,
                    player
                )
            end

            for id, offer in pairs(result) do
                local timeoutMinutes = TimeUtils.convertTicksToMinutes(
                    offer.expiredAtTicks - command.tick
                )
                LoggerService.chat(
                    {
                        ConfigService.getKey('offers.list-element'),
                        id,
                        TimeUtils.minutesToClock(timeoutMinutes),
                        offer.localisedMessage
                    },
                    player.color, 
                    player
                )
            end
        end)

    commands.add_command('yes', { ConfigService.getKey('offers.resolve-yes-help') },
        function(command)
            local player = PlayerUtils.getById(command.player_index)
            local offerId = command.parameter

            local status, result = pcall(
                OfferModuleService.resolve,
                offerId,
                player.index,
                true
            )
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, player)
            end
        end)

    commands.add_command('no', { ConfigService.getKey('offers.resolve-no-help') },
        function(command)
            local player = PlayerUtils.getById(command.player_index)
            local offerId = command.parameter

            local status, result = pcall(
                OfferModuleService.resolve,
                offerId,
                player.index,
                false
            )
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, player)
            end
        end)
end

bootstrap()
