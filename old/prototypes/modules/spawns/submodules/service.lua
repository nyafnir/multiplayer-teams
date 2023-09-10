local this = {}

local points = require('prototypes.modules.spawns.submodules.points')
local entities = require('prototypes.modules.spawns.submodules.entities')

--- Создать новую базу для команды игроков
function this.createSpawn(surface, force)
    local spawnPoint =
        points.getArchimedeanSpiralPoint(spawns.store.step.next())

    -- TODO: check player builds in area then new spawn point while

    --- Стартовая зона имеет радиус в 150 ед. по умолчанию
    local startingRadius = surface.get_starting_area_radius()
    logger.debug('Стартовая зона: ' .. startingRadius .. ' клеток')

    local aboveRadius = startingRadius / 2
    logger.debug('Рядом: ' .. aboveRadius .. ' клеток')
    local nearRadius = startingRadius + spawns.config.options.radius.near
    logger.debug('Недалеко: ' .. nearRadius .. ' клеток')
    local farRadius = nearRadius + spawns.config.options.radius.far
    logger.debug('Далеко: ' .. farRadius .. ' клеток')
    local awayRadius = farRadius * 2
    logger.debug('Очень далеко: ' .. awayRadius .. ' клеток')

    --- Загрузка местоположения на карте для команды игроков
    --- Иначе мы не сможем ничего там менять
    force.chart(surface, {
        {
            x = spawnPoint.x - math.sign(spawnPoint.x) * awayRadius,
            y = spawnPoint.y - math.sign(spawnPoint.y) * awayRadius
        }, {
            x = spawnPoint.x + math.sign(spawnPoint.x) * awayRadius,
            y = spawnPoint.y + math.sign(spawnPoint.y) * awayRadius
        }
    })

    
    logger.debug('Засыпка глубокой и обычной воды.')
    entities.killWater(surface, spawnPoint, aboveRadius)
    logger.debug('Уничтожение вражеских единиц.')
    entities.killBitters(surface, spawnPoint, farRadius)
    logger.debug('Удаление вражеской слизи.')
    entities.callCleaners(surface, spawnPoint, farRadius)
    logger.debug('Удаление ископаемых ресурсов.')
    entities.removeResources(surface, spawnPoint, awayRadius)
    logger.debug('Генерация ископаемых ресурсов.')
    -- entities.generateResources(surface, spawnPoint, aboveRadius, nearRadius, farRadius)

    return spawnPoint
end

return this
