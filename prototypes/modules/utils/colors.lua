---@alias Color table | tuple
---https://lua-api.factorio.com/latest/Concepts.html#Color
--
---@param color1 table
---@param color2 table
---@return boolean
function isEqualRGBAColors(color1, color2)
    return color1.r == color2.r and color1.g == color2.g and color1.b ==
               color2.b and color1.a == color2.a
end

---@param hex string
---@param alpha number | nil = 1
---@return tuple
function convertHexToRGBA(hex, alpha)
    if alpha == nil then alpha = 1 end

    if string.sub(hex, 1, 1) == '#' then hex = string.gsub(hex, '#', '') end

    local red = tonumber(string.sub(hex, 1, 2)) / 255
    local green = tonumber(string.sub(hex, 3, 4)) / 255
    local blue = tonumber(string.sub(hex, 5, 6)) / 255

    return {red, green, blue, alpha} -- short-hand notation
end

---Конвертация RGB в HEX.
---Альфа канал не учитывается.
---@param color table
---@return string
function convertRGBToHex(color)
    return '#' .. math.floor(color.r * 255) .. math.floor(color.g * 255) ..
               math.floor(color.b * 255)
end

---Стандартные цвета которые доступны по всему проекту
---@type table
colors = {
    ---@type tuple
    white = {1, 1, 1, 0},
    ---@type tuple
    orange = {1, 0.64705882352941, 0, 0},
    ---@type tuple
    red = {1, 0, 0, 0},
    ---@type tuple
    yellow = {1, 1, 0, 0},
    ---@type tuple
    grey = {0.5, 0.5, 0.5, 0},
    ---@type tuple
    green = {0.4, 1, 0.4, 0}
}
