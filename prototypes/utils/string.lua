local this = {}

---@param data any
---@return string
function this.convertAnyToString(data)
    if type(data) == 'table' or type(data) == 'LuaCustomTable' then
        return serpent.block(data)
    end

    return tostring(data)
end

return this
