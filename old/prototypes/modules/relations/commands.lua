local this = {}

function this.list(command)
    local player = playerService.getById(command.player_index)

    local list = relationModule.service.listFor(player.force.name)

    list.friends = table.concat(list.friends, ', ')
    if string.len(list.friends) == 0 then
        list.friends = '-'
    end

    list.enemies = table.concat(list.enemies, ', ')
    if string.len(list.enemies) == 0 then
        list.enemies = '-'
    end

    list.neutrals = table.concat(list.neutrals, ', ')
    if string.len(list.neutrals) == 0 then
        list.neutrals = '-'
    end

    player.print({ configService.getKey('relations:list.result-header') }, colorService.list.white)
    player.print({ configService.getKey('relations:list.result-friends'), list.friends }, colorService.list.green)
    player.print({ configService.getKey('relations:list.result-enemies'), list.enemies }, colorService.list.red)
    player.print({ configService.getKey('relations:list.result-neutrals'), list.neutrals }, colorService.list.grey)
end

function this.setEnemy(command)
    local player = playerService.getById(command.player_index)

    local status, result = pcall(relationModule.service.setEnemy, command.parameter, player.index)
    if status == false then
        return player.print(result, colorService.list.red)
    end
end

function this.setFriend(command)
    local player = playerService.getById(command.player_index)

    local status, result = pcall(relationModule.service.setFriend, command.parameter, player.index)
    if status == false then
        return player.print(result, colorService.list.red)
    end
end

function this.setNeutral(command)
    local player = playerService.getById(command.player_index)

    local status, result = pcall(relationModule.service.setNeutral, command.parameter, player.index)
    if status == false then
        return player.print(result, colorService.list.red)
    end
end

function this.switchFriendlyFire(command)
    local player = playerService.getById(command.player_index)

    local status, result = pcall(relationModule.service.switchFriendlyFire, player.index)
    if status == false then
        return player.print(result, colorService.list.red)
    end
end

function this.init()
    ---Если какой-либо консольной команды нет, значит и других нет
    if commands.commands['relations'] == nil then
        commands.add_command('relations', { configService.getKey('relations:list.help') },
            this.list)
        commands.add_command('relation-enemy', { configService.getKey('relations:set:enemy.help') },
            this.setEnemy)
        commands.add_command('relation-friend', { configService.getKey('relations:set:friend.help') }, this.setFriend)
        commands.add_command('relation-neutral', { configService.getKey('relations:set:neutral.help') }, this.setNeutral)

        commands.add_command('friendly-fire', { configService.getKey('relations:friendly-fire.help') },
            this.switchFriendlyFire)
    end
end

return this
