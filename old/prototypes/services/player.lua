local this = {}

---getByNickname
---@param name string
---@return LuaPlayer | nil
function this.getByName(name)
    for _, player in pairs(game.players) do
        if player.name == name then
            return player
        end
    end

    return nil
end

---@param id number
---@return LuaPlayer
function this.getById(id)
    return game.players[id]
end

return this
