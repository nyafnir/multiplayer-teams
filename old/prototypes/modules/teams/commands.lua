local this = {}
local admin = {}

function this.create(command)
    local player = playerService.getById(command.player_index)
    local teamName = command.parameter

    local status, result = pcall(teamModule.service.create, teamName, player.index, player.color)
    if status == false then
        return player.print(result, colorService.list.red)
    end
end

---TODO: вынести в сервис, если нужно будет для GUI
function this.showInfo(command)
    local player = playerService.getById(command.player_index)

    local team
    if command.parameter == nil or command.parameter == '' then
        ---@type MTTeam Здесь никогда не будет `nil`
        ---@diagnostic disable-next-line: assign-type-mismatch
        team = teamModule.service.getByName(player.force.name)
    else
        team = teamModule.service.getByTitle(command.parameter)
        if team == nil then
            return player.print({ configService.getKey('teams:info.error-team-not-founded'), command.parameter },
                colorService.list.yellow)
        end
    end

    local ownerName = 'нет'
    if team.ownerId ~= nil then
        ownerName = playerService.getById(team.ownerId).name
    end

    local countPlayers = Utils.table.getSize(player.force.players)
    player.print({ configService.getKey('teams:info.result-header'), team.name },
        team.color)
    player.print({ configService.getKey('teams:info.result-element'), team.id, team.title, ownerName, countPlayers },
        team.color)
end

---TODO: вынести в сервис, если нужно будет для GUI
function this.showInfoAll(command)
    local player = playerService.getById(command.player_index)

    player.print({ configService.getKey('teams:list.result-header') }, colorService.list.white)

    for _, team in pairs(teamModule.service.getTeams()) do
        local force = game.forces[team.name]
        local countPlayers = Utils.table.getSize(force.players)

        ---Прячем пустые команды
        if countPlayers == 0 then
            goto continue
        end

        local ownerName = 'нет'
        if team.ownerId ~= nil then
            local owner = playerService.getById(team.ownerId)
            ownerName = owner.name
        end

        player.print({ configService.getKey('teams:list.result-element'), team.id, team.title, ownerName, countPlayers }
            , team.color)

        ::continue::
    end
end

---TODO: вынести в сервис, если нужно будет для GUI
function this.showMembers(command)
    local player = playerService.getById(command.player_index)

    local team
    if command.parameter == nil or command.parameter == '' then
        ---@type MTTeam Здесь никогда не будет `nil`
        ---@diagnostic disable-next-line: assign-type-mismatch
        team = teamModule.service.getByName(player.force.name)
    else
        team = teamModule.service.getByTitle(command.parameter)
        if team == nil then
            return player.print({ configService.getKey('teams:players.error-team-not-founded'), command.parameter },
                colorService.list.yellow)
        end
    end

    player.print({ configService.getKey('teams:players.result-header'), team.name }, colorService.list.white)

    local force = game.forces[team.name]
    for _, member in pairs(force.players) do
        player.print({ configService.getKey('teams:players.result-element'), member.index, member.name }
            , member.color)
    end
end

function this.remove(command)
    local player = playerService.getById(command.player_index)

    local status, result = pcall(teamModule.service.remove, player.index)
    if status == false then
        return player.print(result, colorService.list.red)
    end
end

function this.changeTitle(command)
    local player = playerService.getById(command.player_index)
    local title = command.parameter

    local status, result = pcall(teamModule.service.changeTitle, player.index, title)
    if status == false then
        return player.print(result, colorService.list.red)
    end
end

function this.changeColor(command)
    local player = playerService.getById(command.player_index)
    local color = player.color

    local status, result = pcall(teamModule.service.changeColor, color, player.index)
    if status == false then
        return player.print(result, colorService.list.red)
    end
end

function this.kick(command)
    local player = playerService.getById(command.player_index)
    local nickname = command.parameter

    local status, result = pcall(teamModule.service.kick, nickname, player.index)
    if status == false then
        return player.print(result, colorService.list.red)
    end
end

function this.leave(command)
    local player = playerService.getById(command.player_index)

    local status, result = pcall(teamModule.service.leave, player.index)
    if status == false then
        return player.print(result, colorService.list.red)
    end
end

function admin.remove(command)
    local player = playerService.getById(command.player_index)
    local teamTitle = command.parameter

    local status, result = pcall(teamModule.service.admin.remove, teamTitle, player.index)
    if status == false then
        return player.print(result, colorService.list.red)
    end
end

function admin.changeTeamOfPlayer(command)
    local player = playerService.getById(command.player_index)

    if command.parameter == nil then
        return player.print({ configService.getKey('teams:admin:change.error-empty-input') },
            colorService.list.red)
    end

    ---Все до последнего слова - название команды
    local _, _, teamTargetData = string.find(command.parameter or '', "([%s%S]*) [%S]*")
    teamTargetData = teamTargetData:gsub("%W", "") -- удаляем всё кроме букв
    if teamTargetData == '' then
        return player.print({ configService.getKey('teams:admin:change.error-team-not-specified') },
            colorService.list.red)
    end

    ---Последнее слово - никнейм игрока
    local _, _, playerTargetData = string.find(command.parameter or '', "[%s%S]* ([%S]*)$")
    playerTargetData = playerTargetData:gsub("%W", "") -- удаляем всё кроме букв
    if playerTargetData == '' then
        return player.print({ configService.getKey('teams:admin:change.error-player-not-specified') },
            colorService.list.red)
    end

    local status, result = pcall(teamModule.service.admin.changeTeamOfPlayer, teamTargetData, playerTargetData,
        player.index)
    if status == false then
        return player.print(result, colorService.list.red)
    end
end

function this.sendInvite(command)
    local player = playerService.getById(command.player_index)
    local nickname = command.parameter

    local status, result = pcall(teamModule.service.sendInvite, nickname, player.index)
    if status == false then
        return player.print(result, colorService.list.red)
    end
end

function this.init()
    ---Если какой-либо консольной команды нет, значит и других нет
    if commands.commands['team-create'] ~= nil then return end
    commands.add_command('team-create', { configService.getKey('teams:create.help') },
        this.create)
    commands.add_command('team-info', { configService.getKey('teams:info.help') }, this.showInfo)
    commands.add_command('team-list', { configService.getKey('teams:list.help') }, this.showInfoAll)
    commands.add_command('team-players', { configService.getKey('teams:players.help') },
        this.showMembers)
    commands.add_command('team-remove', { configService.getKey('teams:remove.help') },
        this.remove)
    commands.add_command('team-title', { configService.getKey('teams:title.help') },
        this.changeTitle)
    commands.add_command('team-color', { configService.getKey('teams:color.help') },
        this.changeColor)

    commands.add_command('team-kick', { configService.getKey('teams:kick.help') }, this.kick)
    commands.add_command('team-leave', { configService.getKey('teams:leave.help') },
        this.leave)

    commands.add_command('team-admin-remove', { configService.getKey('teams:admin:remove.help') },
        admin.remove)
    commands.add_command('team-admin-change', { configService.getKey('teams:admin:change.help') },
        admin.changeTeamOfPlayer)

    commands.add_command('team-invite', { configService.getKey('teams:invite.help') },
        this.sendInvite)
end

this.admin = admin
return this
