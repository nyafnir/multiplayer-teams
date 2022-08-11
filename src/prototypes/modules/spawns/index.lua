local this = {
    config = require('prototypes.modules.spawns.config'),
    store = require('prototypes.modules.spawns.store.index'),
    controller = require('prototypes.modules.spawns.controller'),
    commands = require('prototypes.modules.spawns.commands')
}

function this._on_any()
    if this.config.enable == true then this.commands.init() end
end

function this.on_init() this._on_any() end

function this.on_load() this._on_any() end

return this
