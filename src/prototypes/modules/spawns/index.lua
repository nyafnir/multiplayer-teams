local this = {
    config = require('prototypes.modules.spawns.config'),
    -- store = require('prototypes.modules.spawns.store.index'),
    base = require('prototypes.modules.spawns.base'),
    -- events = require('prototypes.modules.spawns.events'),
    -- commands = require('prototypes.modules.spawns.commands')
}

function this.start()
    if getConfig('spawns:enable') == true then
        -- this.commands.addCmds()
    end
end

return this
