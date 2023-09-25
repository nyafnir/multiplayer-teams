PlayerUtils = {}

--- aka `getByNickname`
--- @param name string
--- @return LuaPlayer | nil
function PlayerUtils.getByName(name)
    for _, player in pairs(game.players) do
        if player.name == name then
            return player
        end
    end

    return nil
end

--- Возвращает сущность игрока по идентификатору.
--- Если не найден, то напишет ошибку.
--- @param id number
--- @return LuaPlayer
function PlayerUtils.getById(id)
    local player = game.players[id]

    if player == nil then
        error({ ConfigService.getKey('utils:player.error-player-not-founded') })
    end

    return player
end
