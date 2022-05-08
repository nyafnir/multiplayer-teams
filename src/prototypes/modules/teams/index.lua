local this = {
    config = require('prototypes.modules.teams.config'),
    store = require('prototypes.modules.teams.store.index'),
    base = require('prototypes.modules.teams.base'),
    events = require('prototypes.modules.teams.events'),
    commands = require('prototypes.modules.teams.commands')
}

function this.start()
    if getConfig('teams:enable') == true then
        this.commands.addCmds()
        script.on_event(defines.events.on_player_created, this.events.onJoinNewPlayer)
    end
end

return this
