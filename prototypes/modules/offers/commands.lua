local this = {}

function this.list(command)
    local player = playerService.getById(command.player_index)

    local status, result = pcall(offerModule.service.list, player.index)
    if status == false then
        return player.print(result, colorService.list.red)
    end
end

function this.accept(command)
    local player = playerService.getById(command.player_index)
    local offerId = command.parameter

    local status, result = pcall(offerModule.service.accept, offerId, player.index)
    if status == false then
        return player.print(result, colorService.list.red)
    end
end

function this.cancel(command)
    local player = playerService.getById(command.player_index)
    local offerId = command.parameter

    local status, result = pcall(offerModule.service.cancel, offerId, player.index)
    if status == false then
        return player.print(result, colorService.list.red)
    end
end

function this.init()
    ---Если какой-либо консольной команды нет, значит и других нет
    if commands.commands['mt-accept'] ~= nil then return end

    commands.add_command('offers', { configService.getKey('offer:list.help') },
        this.list)
    commands.add_command('mt-accept', { configService.getKey('offer:accept.help') },
        this.accept)
    commands.add_command('mt-cancel', { configService.getKey('offer:cancel.help') },
        this.cancel)
end

return this
