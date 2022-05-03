function giveItemToPlayer(playerId, itemName, amount)
    local player = getPlayerById(playerId)
    player.insert({
        name = itemName,
        count = amount
    })
end

function getPlayerByName(name)
    if name == nil then
        return nil
    end

    for _, player in pairs(game.players) do
        if player.name == name then
            return player
        end
    end

    return nil
end

function getPlayerById(id)
    if id == nil then
        return nil
    end

    -- for player in global.players do
    --     if player.index == id then
    --         return player
    --     end
    -- end

    return game.players[id]
end

