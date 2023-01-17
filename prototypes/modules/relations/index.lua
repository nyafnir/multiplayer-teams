local this = {
    config = require('prototypes.modules.relations.config'),
    store = require('prototypes.modules.relations.store.index'),
    base = require('prototypes.modules.relations.base'),
    events = require('prototypes.modules.relations.events'),
    commands = require('prototypes.modules.relations.commands')
}

local function on_any()
    if this.config.enabled then
        this.commands.init()
        script.on_event(defines.events.on_forces_merging,
                        this.events.onRemovingForce)
    end
end

function this.on_init() on_any() end

function this.on_load() on_any() end

return this
