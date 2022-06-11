local this = {}

-- Нарисовать квадрат (начиная с левой верхней точки)
--- на surface
--- из entityName 
--- где каждый entityName в количестве amount
--- в опциях укажите левую верхнюю точку, сколько клеток вправо и вниз, а так же шаг:
-- @param options {{ leftTopPoint: {x,y}, limits: {x,y}, steps: {x,y} }}
function this.drawRectangle(surface, entityName, amount, options)
    -- Перебираем все клетки по столбцам сверху внизу по указанном шагу до указанного предела
    for x = options.leftTopPoint.x, options.limits.x, options.steps.x do
        for y = options.leftTopPoint.y, options.limits.y, options.steps.y do
            surface.create_entity({
                name = entityName,
                amount = amount,
                position = {x, y}
            })
        end
    end
end

--- Преобразовать радиус в координаты для заливки области в виде квадрата и вернуть их
--- этот метод учитывает отрицательность координат
function this.convertRadiusToSquareOptions(surface, center, radius, entityName, amount)
    local leftTopPoint = {
        x = math.floor(center.x - radius * math.sign(center.x)),
        y = math.floor(center.y - radius * math.sign(center.y))
    }
    local limits = {
        x = math.floor(leftTopPoint.x + radius * 2 * math.sign(center.x)),
        y = math.floor(leftTopPoint.y + radius * 2 * math.sign(center.y))
    }
    local steps = {
        x = math.sign(center.x),
        y = math.sign(center.y)
    }

    return {
        leftTopPoint = leftTopPoint,
        limits = limits,
        steps = steps
    }
end

--- Рисование линии из started в ended:
-- @param started {{ x: number, y: number }}
-- @param ended {{ x: number, y: number }}
--- сущностью entityName
--- в количестве amount
function this.drawLine(surface, entityName, amount, started, ended)
    local x = started.x
    local y = started.y

    -- учитываем отрицательность координат
    local stepX = 1
    if started.x > ended.x then
        stepX = -1
    end

    -- учитываем отрицательность координат
    local stepY = 1
    if started.y > ended.y then
        stepY = -1
    end

    -- используем запоминание прошлых координат для ускорения заливки
    local memoization = {}
    while x ~= ended.x or y ~= ended.y do
        local pointName = tostring(x) .. '' .. tostring(y)
        if memoization[pointName] ~= nil then
            goto continue
        else
            memoization[pointName] = true
        end

        surface.create_entity({
            name = entityName,
            amount = amount,
            position = {x, y}
        })

        ::continue::

        if started.x ~= ended.x then
            x = x + stepX
        end

        if started.y ~= ended.y then
            y = y + stepY
        end
    end
end

-- @param options { radius: number, center: { x: number, y: number } }
function this.drawCircle(surface, entityName, amount, options)
    local _x = options.center.x
    local _y = options.center.y

    local x = 0
    local y = options.radius
    local delta = 3 - 2 * y

    -- Source: https://www.cyberforum.ru/opengl/thread1806553.html
    while x <= y do
        -- @type {Record<number, { x: number, y: number }>}
        local octants = {}

        octants[1] = {
            x = _x + x,
            y = _y + y
        }
        octants[2] = {
            x = y + _x,
            y = x + _y
        }
        octants[3] = {
            x = y + _x,
            y = -x + _y
        }
        octants[4] = {
            x = _x + x,
            y = _y - y
        }
        octants[5] = {
            x = _x - x,
            y = _y - y
        }
        octants[6] = {
            x = -y + _x,
            y = -x + _y
        }
        octants[7] = {
            x = -y + _x,
            y = x + _y
        }
        octants[8] = {
            x = _x - x,
            y = _y + y
        }

        this.drawLine(surface, entityName, amount, octants[7], octants[6])
        this.drawLine(surface, entityName, amount, octants[8], octants[5])
        this.drawLine(surface, entityName, amount, octants[1], octants[4])
        this.drawLine(surface, entityName, amount, octants[2], octants[3])

        if delta < 0 then
            delta = delta + 2 * x + 3
        else
            delta = delta + (2 * (x - y)) + 5
            y = y - 1
        end
        x = x + 1
    end
end

return this
