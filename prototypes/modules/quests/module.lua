local this = {
    config = require('prototypes.modules.quests.config'),
    service = require('prototypes.modules.quests.service'),
}

local function on_any()
    if this.config.enabled then
        loggerService.debug('Модуль квестов пуст.')
    end
end

function this.on_init() on_any() end

function this.on_load() on_any() end

return this
