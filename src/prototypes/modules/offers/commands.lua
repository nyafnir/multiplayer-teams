local function bootstrap()
    --- Если какой-либо консольной команды нет, значит и других нет
    if commands.commands['offers'] ~= nil then return end

    commands.add_command('offers', { 'mt.offers.list.help' },
        function(command)
            local player = PlayerUtils.getById(command.player_index)

            local status, result = pcall(OfferModuleService.getAllByPlayer, player.index)
            if status == false then
                return LoggerService.chat(result, ColorUtils.colors.red, player)
            end

            LoggerService.chat({ 'mt.offers.list.header' }, nil, player)

            if TableUtils.getSize(result) == 0 then
                return LoggerService.chat({ 'mt.offers.list.empty' }, nil, player)
            end

            for id, offer in pairs(result) do
                local timeoutMinutes = TimeUtils.convertTicksToMinutes(
                    offer.expiredAtTicks - command.tick
                )
                LoggerService.chat(
                    {
                        'mt.offers.list.element',
                        id,
                        TimeUtils.minutesToClock(timeoutMinutes),
                        offer.localisedMessage
                    },
                    nil,
                    player
                )
            end
        end)

    commands.add_command('yes', { 'mt.offers.resolve.yes.help' },
        function(command)
            local player = PlayerUtils.getById(command.player_index)
            local offerId = tonumber(command.parameter)

            LoggerService.chat({ 'mt.offers.resolve.yes.result' }, nil, player)

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

    commands.add_command('no', { 'mt.offers.resolve.no.help' },
        function(command)
            local player = PlayerUtils.getById(command.player_index)
            local offerId = tonumber(command.parameter)

            LoggerService.chat({ 'mt.offers.resolve.no.result' }, nil, player)

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
