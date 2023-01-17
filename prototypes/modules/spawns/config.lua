return {
    --- Вкл / выкл модуль
    enabled = getConfig('spawns:enabled'),
    --- Архимедова спираль для генерации точек для новых баз
    archimedeanSpiral = {
        step = getConfig('spawns:archimedean-spiral:step'),
        distance = getConfig('spawns:archimedean-spiral:distance')
    },
    --- Настройки базы
    options = {
        radius = {
            near = getConfig('spawns:options:radius:near'),
            far = getConfig('spawns:options:radius:far')
        },
        --- Смена расположения своей базы
        respawn = {
            --- время в течение которого можно поменять место
            timeout = {
                minutes = getConfig('spawns:options:respawn:timeout'),
                ticks = convertMinutesToTicks(getConfig(
                                                  'spawns:options:respawn:timeout'))
            }
        },
        --- Добавление ресурсов вокруг базы:
        --- - дубликаты являются отдельными месторождениями
        resources = getConfig('spawns:options:resources')
    }
}
