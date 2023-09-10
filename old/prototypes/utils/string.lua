local this = {}

---@param data any
---@return string
function this.convertAnyToString(data)
    if type(data) == 'table' or type(data) == 'LuaCustomTable' then
        return serpent.block(data)
    end

    return tostring(data)
end

---@param inputstr string
---@param sep string
---@return string[]
function this.split(inputstr, sep)
    if sep == nil then sep = "%s" end

    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end

    return t
end

return this
