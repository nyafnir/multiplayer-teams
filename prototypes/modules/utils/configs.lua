local prefix = 'multiplayer-teams:'

function getConfigFullName(name) return prefix .. name end

--- Получение значения настройки (`name` без префикса)
--- Всегда возвращает строку
function getConfig(name)
    -- if player ~= nil then
    --     local runtime_per_user = player.mod_settings[getConfigFullName(name)]
    --     if runtime_per_user ~= nil then
    --         return runtime_per_user.value
    --     else
    --         return nil
    --     end
    -- end

    local startup = settings.startup[getConfigFullName(name)]
    if startup ~= nil then return startup.value end

    local runtime_global = settings.global[getConfigFullName(name)]
    if runtime_global ~= nil then return runtime_global.value end

    return nil
end
