local this = {
    config = require('prototypes.modules.relations.config'),
    store = require('prototypes.modules.relations.store.index'),
    base = require('prototypes.modules.relations.base'),
    commands = require('prototypes.modules.relations.commands')
}

function this.start()
    if this.config.enable then
        this.commands.addCmds()
    end
end

return this
