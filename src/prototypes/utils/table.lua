TableUtils = {}

---@param table table | LuaCustomTable
---@return number
function TableUtils.getSize(table)
    if next(table) == nil then
        return 0
    end

    if type(table) == 'LuaCustomTables' then
        return #table
    end

    return table_size(table)
end
