local prefix = 'multiplayer-teams:'

---@param name string
---@return string
function getConfigFullName(name) return prefix .. name end

---Получение значения настройки `name` (указывать префикс не нужно).
---@param name string
---@return string | nil
function getConfig(name)
    ---@type string | nil
    local startup = settings.startup[getConfigFullName(name)]
    if startup then return startup.value end

    ---@type string | nil
    local runtime_global = settings.global[getConfigFullName(name)]
    if runtime_global then return runtime_global.value end

    return nil
end

---@param name string
---@param player LuaPlayer | nil
---@return string | nil
function getConfigFor(name, player)
    if player == nil then return end

    ---@type string | nil
    local runtime_per_user = player.mod_settings[getConfigFullName(name)]
    if runtime_per_user then return runtime_per_user.value end

    return nil
end
