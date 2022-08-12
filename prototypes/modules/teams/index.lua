local this = {
    config = require('prototypes.modules.teams.config'),
    store = require('prototypes.modules.teams.store.index'),
    base = require('prototypes.modules.teams.base'),
    events = require('prototypes.modules.teams.events'),
    commands = require('prototypes.modules.teams.commands')
}

function this._on_any()
    if this.config.enable then
        this.commands.init()
        script.on_event(defines.events.on_player_created,
                        this.events.onJoinNewPlayer)
        script.on_event(defines.events.on_forces_merging,
                        this.events.onRemovingForce)
    end
end

function this.on_init() this._on_any() end

function this.on_load() this._on_any() end

return this
