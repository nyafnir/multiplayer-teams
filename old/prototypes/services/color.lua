local this = {
    list = {
        white = { 1, 1, 1, 0 },
        orange = { 1, 0.64705882352941, 0, 0 },
        red = { 1, 0, 0, 0 },
        yellow = { 1, 1, 0, 0 },
        grey = { 0.5, 0.5, 0.5, 0 },
        green = { 0.4, 1, 0.4, 0 }
    }
}

---@alias Color table | tuple
---https://lua-api.factorio.com/latest/Concepts.html#Color

---@param color1 table
---@param color2 table
---@return boolean
function this.isEqualRGBAColors(color1, color2)
    return color1.r == color2.r and color1.g == color2.g and color1.b ==
        color2.b and color1.a == color2.a
end

---@param hex string
---@param alpha number | nil = 1
function this.convertHexToRGBA(hex, alpha)
    if string.sub(hex, 1, 1) == '#' then
        hex = string.gsub(hex, '#', '')
    end

    local red = tonumber(string.sub(hex, 1, 2)) / 255
    local green = tonumber(string.sub(hex, 3, 4)) / 255
    local blue = tonumber(string.sub(hex, 5, 6)) / 255

    return { red = red, green = green, blue = blue, alpha = alpha or 1 } -- short-hand notation
end

---Конвертация RGB в HEX.
---Альфа канал не учитывается.
---@param color table
---@return string
function this.convertRGBToHex(color)
    return '#' .. math.floor(color.r * 255) .. math.floor(color.g * 255) ..
        math.floor(color.b * 255)
end

return this
