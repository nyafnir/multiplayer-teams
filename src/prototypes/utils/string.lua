StringUtils = {}

--- Конвертирует какие-либо данные в строковый формат.
--- Например для логов.
--- @param data any
--- @return string
function StringUtils.convertAnyToString(data)
    if type(data) == 'table' or type(data) == 'LuaCustomTable' then
        return serpent.block(data)
    end

    return tostring(data)
end

--- Делит предложение на части по указанному разделителю и
--- возвращает массив таких частей
--- @param sentence string
--- @param delimiter string
--- @return string[]
function StringUtils.split(sentence, delimiter)
    if delimiter == nil then delimiter = "%s" end

    local words = {}
    for word in string.gmatch(sentence, "([^" .. delimiter .. "]+)") do
        table.insert(words, word)
    end

    return words
end
