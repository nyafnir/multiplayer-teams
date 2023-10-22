ColorUtils = {}

--- Список цветов по умолчанию (тип `Color.0`)
ColorUtils.colors = {
    white = { r = 1, g = 1, b = 1, a = 0 },
    orange = { r = 1, g = 0.64705882352941, b = 0, a = 0 },
    red = { r = 1, g = 0, b = 0, a = 0 },
    yellow = { r = 1, g = 1, b = 0, a = 0 },
    grey = { r = 0.5, g = 0.5, b = 0.5, a = 0 },
    green = { r = 0.4, g = 1, b = 0.4, a = 0 }
}

--- Сравнивает цвета путем прямого сравнения значений
--- @param color1 Color.0
--- @param color2 Color.0
--- @return boolean
function ColorUtils.isEqualRGBAColors(color1, color2)
    return color1.r == color2.r and color1.g == color2.g and color1.b ==
        color2.b and color1.a == color2.a
end

--- Конвертирует цвет из формата HEX в `Color.0`.
--- Поддерживает отсекание `#`.
--- @param hex string
--- @param alpha number | nil по умолчанию: 1
function ColorUtils.convertHexToRGBA(hex, alpha)
    if alpha == nil then
        alpha = 1
    end

    if string.sub(hex, 1, 1) == '#' then
        hex = string.gsub(hex, '#', '')
    end

    local red = tonumber(string.sub(hex, 1, 2)) / 255
    local green = tonumber(string.sub(hex, 3, 4)) / 255
    local blue = tonumber(string.sub(hex, 5, 6)) / 255

    return { r = red, g = green, b = blue, a = alpha }
end

--- Конвертация RGB в HEX.
--- Альфа канал не учитывается.
--- @param color Color.0
--- @return string
function ColorUtils.convertRGBToHex(color)
    return '#' .. math.floor(color.r * 255) .. math.floor(color.g * 255) ..
        math.floor(color.b * 255)
end

--- Конвертация цвета в тип Color.0.
--- С альфа каналом.
--- @param color Color
--- @return Color.0
function ColorUtils.convertColorToColor0(color)
    if color.r ~= nil or color.g ~= nil or color.b ~= nil then
        --- @type Color.0
        return color
    end

    return { r = color[1], g = color[2], b = color[3], a = color[4] }
end
