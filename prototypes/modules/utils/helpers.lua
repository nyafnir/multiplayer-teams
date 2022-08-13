---@param table table | LuaCustomTable
---@return number
function getSize(table)
    if next(table) == nil then return 0 end

    if type(table) == 'LuaCustomTables' then return #table end

    return table_size(table)
end

---@param minutes number
---@return number
function convertMinutesToTicks(minutes) return 60 * 60 * tonumber(minutes) end

---@param num number
---@return number
function math.sign(num)
    if num < 0 then
        return -1
    else
        return 1
    end
end

---@param data any
---@return string
function convertAnyToString(data)
    if type(data) == 'table' or type(data) == 'LuaCustomTable' then
        return serpent.block(data)
    end

    return tostring(data)
end
