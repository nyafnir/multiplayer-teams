local this = {
    config = require('prototypes.modules.relations.config'),
    store = require('prototypes.modules.relations.store.index'),
    base = require('prototypes.modules.relations.base'),
    events = require('prototypes.modules.relations.events'),
    commands = require('prototypes.modules.relations.commands')
}

function this.start()
    if this.config.enable then
        this.commands.addCmds()
        script.on_event(defines.events.on_forces_merging, this.events.onRemovingForce)
    end
end

return this
