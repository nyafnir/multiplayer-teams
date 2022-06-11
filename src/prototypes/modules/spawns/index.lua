local this = {
    config = require('prototypes.modules.spawns.config'),
    store = require('prototypes.modules.spawns.store.index'),
    base = require('prototypes.modules.spawns.base'),
    commands = require('prototypes.modules.spawns.commands')
}

function this.start()
    if this.config.enable == true then
        this.commands.init()
    end
end

return this
