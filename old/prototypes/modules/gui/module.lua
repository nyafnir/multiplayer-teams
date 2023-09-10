local this = {
    config = {
        enabled = configService.get('gui:enabled')
    },
    events = require('prototypes.modules.gui.events')
}

local function on_any() end

function this.on_init() on_any() end

function this.on_load() on_any() end

return this
