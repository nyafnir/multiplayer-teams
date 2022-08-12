function getSize(table)
    if table == nil then return 0 end

    if type(table) ~= 'LuaCustomTables' then return table_size(table) end

    return #table
end

function convertMinutesToTicks(minutes) return 60 * 60 * tonumber(minutes) end

function math.sign(num)
    if num < 0 then
        return -1
    else
        return 1
    end
end
