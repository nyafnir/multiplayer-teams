local this = {}

-- function this.getArchimedeanSpiralPoints(min, max)
--     local points = {}

--     local distance = spawns.config.archimedeanSpiral.distance
--     local step = spawns.config.archimedeanSpiral.step

--     for angel = min, max, step do
--         local r = distance * angel
--         local x = r * math.cos(angel)
--         local y = r * math.sin(angel)
--         table.insert(points, {
--             x = x,
--             y = y
--         })
--     end

--     return points
-- end

function this.getArchimedeanSpiralPoint(angel)
    local distance = spawns.config.archimedeanSpiral.distance

    local r = distance * angel
    local x = r * math.cos(angel)
    local y = r * math.sin(angel)

    return {
        x = x,
        y = y
    }
end

return this
