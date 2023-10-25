PlayerUtils = {}

--- aka `getByNickname`.
--- - Менее эффективен, чем получение по идентификатору.
--- - Если не найден, то выбросит локализованную ошибку.
--- @param name string
--- @return LuaPlayer
function PlayerUtils.getByName(name)
    for _, player in pairs(game.players) do
        if player.name == name then
            return player
        end
    end

    error({ 'mt.errors.target-player-not-found', name })
end

--- Возвращает сущность игрока по идентификатору.
--- - Если не найден, то выбросит локализованную ошибку.
--- @param id number
--- @return LuaPlayer
function PlayerUtils.getById(id)
    local player = game.get_player(id)

    if player == nil then
        error({ 'mt.errors.target-player-not-found', id })
    end

    return player
end
