local this = {}

local service = require('prototypes.modules.spawns.submodules.service')

--- Бросить базу и создать новую
function this.respawn(surface, force)
    --- TODO: Проверяем таймер, что можно сменить местоположение

    --- Получаем координаты новой базы
    local spawnPoint = service.createSpawn(surface, force)

    --- Показываем на карте в режиме отладки
    logger.debug('[gps=' .. spawnPoint.x .. ',' .. spawnPoint.y .. ']')

    --- TODO: Выставляем таймер на сохранение местоположения

    --- Изменяем место появления для всей команды
    force.set_spawn_position(spawnPoint, surface)

    --- Перемещаем всю команду на новое место
    for _, member in pairs(force.players) do member.teleport(spawnPoint) end
end

return this
