--- В этом файле подключение остальных файлов в проект

--- Доступ к настройкам без префикса (только в этом файле)
local function config(name)
    return settings.startup['multiplayer-teams:' .. name].value
end

-- require('prototypes.?')
