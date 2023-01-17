local this = {
    config = require('prototypes.modules.spawns.config'),
    store = require('prototypes.modules.spawns.store.index'),
    controller = require('prototypes.modules.spawns.controller'),
    commands = require('prototypes.modules.spawns.commands')
}

local function on_any()
    if this.config.enabled == true then this.commands.init() end
end

function this.on_init() on_any() end

function this.on_load() on_any() end

return this
