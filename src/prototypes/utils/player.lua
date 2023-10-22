PlayerUtils = {}

--- aka `getByNickname`.
--- Менее эффективен, чем получение по идентификатору.
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
--- Если не найден, то выбросит локализованную ошибку.
--- @param id number
--- @return LuaPlayer
function PlayerUtils.getById(id)
    local player = game.get_player(id)

    if player == nil then
        error({ ConfigService.getKey('utils:player.error-player-not-found') })
    end

    return player
end
