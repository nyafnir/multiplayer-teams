local this = {}

---@param table table | LuaCustomTable
---@return number
function this.getSize(table)
    if next(table) == nil then
        return 0
    end

    if type(table) == 'LuaCustomTables' then
        return #table
    end

    return table_size(table)
end

return this