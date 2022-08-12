local this = {}

function this.respawn(command)
    local player = getPlayerById(command.player_index)
    spawns.controller.respawn(player.surface, player.force)
end

--- Загрузка консольных команд в общий список 
function this.init()
    --- Если какой-либо консольной команды (из списка тех что мы загружаем) нет, то
    --- значит и других нет
    if commands.commands['respawn'] ~= nil then return end

    commands.add_command('respawn', {'spawns:help.respawn'}, this.respawn)
end

--- Удаление консольных команд из общего списка
function this.destroy()
    --- Если консольной команды нет, то удаление вернёт ложь
    commands.remove_command('respawn')
end

return this
