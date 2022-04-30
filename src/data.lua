--- В этом файле подключение остальных файлов в проект

--- Доступ к настройкам без префикса (только в этом файле)
local function config(name)
    return settings.startup['multiplayer-teams:' .. name].value
end

if config('economy-enable') then 
    require('prototypes.modules.economy.index')

    if config('quests-enable') then 
        require('prototypes.modules.quests.index')
    end 
end

require('prototypes.modules.teams.index')
require('prototypes.modules.relations.index')
require('prototypes.modules.utils.index')
require('prototypes.modules.gui.index')
