--- https://lua-api.factorio.com/latest/Libraries.html
function getSize(table)
    if table == nil then
        return 0
    end

    if type(table) ~= 'LuaCustomTables' then
        return table_size(table)
    end

    return #table
end

function convertMinutesToTicks(minutes)
    return 60 * 60 * tonumber(minutes)
end
