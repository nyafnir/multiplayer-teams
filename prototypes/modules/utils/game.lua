---@param playerId number
---@param itemName string
---@param amount number
---@return void
function giveItemToPlayer(playerId, itemName, amount)
    local player = getPlayerById(playerId)
    player.insert({
        name = itemName,
        count = amount
    })
end

---@param name string | nil
---@return LuaPlayer | nil
function getPlayerByName(name)
    if name == nil then return nil end

    for _, player in pairs(game.players) do
        if player.name == name then return player end
    end

    return nil
end

---@param id number | nil
---@return LuaPlayer | nil
function getPlayerById(id)
    if id == nil then return nil end
    return game.players[id]
end

