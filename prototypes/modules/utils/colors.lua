function isEqualRGBAColors(color1, color2)
    return color1.r == color2.r and color1.g == color2.g and color1.b ==
               color2.b and color1.a == color2.a
end

function convertHexToRGBA(hex, alpha)
    if alpha == nil then alpha = 1 end

    if string.sub(hex, 1, 1) == '#' then hex = string.gsub(hex, '#', '') end

    local r = tonumber(string.sub(hex, 1, 2)) / 255
    local g = tonumber(string.sub(hex, 3, 4)) / 255
    local b = tonumber(string.sub(hex, 5, 6)) / 255

    return {
        r = r,
        g = g,
        b = b,
        a = alpha
    }
end

function convertRGBToHex(color)
    return '#' .. math.floor(color.r * 255) .. math.floor(color.g * 255) ..
               math.floor(color.b * 255)
end

-- Стандартные цвета которые доступны по всему проекту
colors = {
    white = {
        r = 1,
        g = 1,
        b = 1,
        a = 0
    },
    orange = {
        r = 1,
        g = 0.64705882352941,
        b = 0,
        a = 0
    },
    red = {
        r = 1,
        g = 0,
        b = 0,
        a = 0
    },
    yellow = {
        r = 1,
        g = 1,
        b = 0,
        a = 0
    },
    grey = {
        r = 0.5,
        g = 0.5,
        b = 0.5,
        a = 0
    },
    green = {
        r = 0.4,
        g = 1,
        b = 0.4,
        a = 0
    }
}
