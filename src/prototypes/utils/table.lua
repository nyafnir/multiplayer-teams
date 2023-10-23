TableUtils = {}

--- Возвращает размер таблицы
--- @param table table | LuaCustomTable
--- @return number
function TableUtils.getSize(table)
    if next(table) == nil then
        return 0
    end

    if type(table) == 'LuaCustomTables' then
        return #table
    end

    return table_size(table)
end

--- Проверяет тип значения
--- @param value unknown
--- @return boolean
function TableUtils.isTable(value)
    if type(value) == 'table' or type(value) == 'LuaCustomTables' then
        return true
    end

    return false
end
