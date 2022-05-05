-- Стандартные цвета которые доступны по всему проекту
color = {
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
    }
}

--- Работает только с RGBA table
function isEqualColors(color1, color2)
    return color1.r == color2.r and color1.g == color2.g and color1.b == color2.b and color1.a == color2.a
end
