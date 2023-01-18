local this = {
    config = {
        ---Используется в настроках, локализации и именовании сущностей
        prefix = 'mt',
        ---Используется в путях к файлам мода
        prefixRoot = '__MultiplayerTeams__'
    }
}

---@param name string
---@return string
function this.getKey(name)
    return this.config.prefix .. ':' .. name
end

---Получение значения настройки `name` (указывать префикс не нужно).
---@param name string
---@return any | nil
function this.get(name)
    ---@type string | nil
    local startup = settings.startup[this.getKey(name)]
    if startup then
        return startup.value
    end

    if settings.global ~= nil then
        ---@type string | nil
        local runtime_global = settings.global[this.getKey(name)]
        if runtime_global then
            return runtime_global.value
        end
    end

    return nil
end

---Получение значения настройки `name` у игрока (указывать префикс не нужно).
---@param player LuaPlayer
---@param name string
---@return string | nil
function this.getFor(player, name)
    ---@type string | nil
    local runtime_per_user = settings.get_player_settings(player.index)[this.getKey(name)]

    if runtime_per_user then
        return runtime_per_user.value
    end

    return nil
end

return this
