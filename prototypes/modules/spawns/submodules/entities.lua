local this = {}

local draws = require('prototypes.modules.spawns.submodules.draws')

function this.getEntities(surface, point, radius, name)
    return surface.find_entities_filtered({
        position = point,
        radius = radius,
        name = name
    })
end

function this.getTiles(surface, point, radius, name)
    return surface.find_tiles_filtered({
        position = point,
        radius = radius,
        name = name
    })
end

--- Засыпать воду, если в радиусе от точки
function this.killWater(surface, point, radius)
    -- Определяем точки для засыпки
    local landfillTiles = {}

    -- Ищем воду
    local waterTiles = this.getTiles(surface, point, radius, 'water')
    for _, tile in pairs(waterTiles) do
        table.insert(landfillTiles, {
            name = "landfill",
            position = tile.position
        })
    end

    -- Ищем глубокую воду
    local deepwaterTiles = this.getTiles(surface, point, radius, 'deepwater')
    for _, tile in pairs(deepwaterTiles) do
        table.insert(landfillTiles, {
            name = "landfill",
            position = tile.position
        })
    end

    if getSize(landfillTiles) > 0 then surface.set_tiles(landfillTiles) end
end

--- Уничтожить всё что связано с кусаками в радиусе от точки
function this.killBitters(surface, point, radius)
    local list = surface.find_entities_filtered({
        position = {point.x, point.y},
        radius = radius,
        force = 'enemy' -- команда кусак
    })

    for _, entity in pairs(list) do
        if entity.can_be_destroyed() then

            entity.destroy()
        else
            entity.deplete()
        end
    end
end

--- Убрать слизь с земли от кусак в радиусе
function this.callCleaners(surface, point, radius)
    -- local left_top = {point.x - radius, point.y - radius}
    -- local right_bottom = {point.x + radius, point.y + radius}
    -- local area = {left_top, right_bottom}

    -- local arrayDecorativeResult = surface.find_decoratives_filtered({
    --     area = area,
    --     name = 'enemy-decal'
    -- })

    -- for _, decorativeResult in pairs(arrayDecorativeResult) do
    --     logger.debug(decorativeResult)
    -- end

    logger(
        'Декорации воссозданы, чтобы убрать слизь от кусак')
    surface.regenerate_decorative()
end

--- Удалить все ресурсы в радиусе
function this.removeResources(surface, point, radius)
    -- local list = this.getEntities(surface, point, radius, '?')

    -- for _, entity in pairs(list) do
    --     if entity.can_be_destroyed() then
    --         entity.deplete()
    --     end
    -- end
end

--- Разместить ресурсы вокруг точки в пределах радиусов
function this.generateResources(surface, spawnPoint, aboveRadius, nearRadius,
                                farRadius)
    for resource in spawns.config.resources do
        -- Определяем зону местоположения
        local zone = {
            from = nil,
            to = nil
        }
        if resource.location == 'above' then zone.to = aboveRadius end
        if resource.location == 'near' then
            zone.from = aboveRadius
            zone.to = nearRadius
        end
        if resource.location == 'far' then
            zone.from = nearRadius
            zone.to = farRadius
        end

        -- Тип: заливки в указанном радиусе
        if resource.type == 'fill' then
            draws.fillCircle(surface, resource.name, resource.amount, {
                radius = resource.radius,
                center = points.getPointAbove(surface, spawnPoint, zone)
            })
            goto continue
        end

        -- Тип: несколько точек в указанном радиусе
        if resource.type == 'dotted' then
            draws.drawPointsInRadius(surface, points.getPointAbove(surface,
                                                                   spawnPoint,
                                                                   zone),
                                     resource.name, resource.count,
                                     resource.amount, resource.radius)
            -- goto continue
        end

        ::continue::
    end
end

return this
