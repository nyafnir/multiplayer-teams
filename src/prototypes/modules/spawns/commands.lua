local this = {}

-- Бросить текущую базу и создать новую
function this.respawn(command)
    local player = getPlayerById(command.player_index)
    local force = player.force
    local surface = player.surface

    -- Получаем координаты новой базы
    local spawnPoint = spawns.base.generateSpawn(surface)

    -- Изменяем место появления для всей команды
    force.set_spawn_position(spawnPoint, surface)

    -- Показываем на карте в режиме отладки
    logger('[gps=' .. spawnPoint.x .. ',' .. spawnPoint.y .. ']')

    -- Перемещаем всю команду на новое место
    for _, member in pairs(force.players) do
        member.teleport(spawnPoint)
    end
end

-- Загрузка консольных команд в общий список 
function this.init()
    -- Если какой-либо консольной команды (из списка тех что мы загружаем) нет, то
    -- значит и других нет
    if commands.commands['respawn'] ~= nil then
        return
    end

    commands.add_command('respawn', {'spawns:help.info'}, spawns.commands.respawn)
end

-- Удаление консольных команд из общего списка
function this.destroy()
    -- Если консольной команды нет, то удаление вернёт ложь

    commands.remove_command('respawn')
end

return this
