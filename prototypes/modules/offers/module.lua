require('prototypes.modules.offers.types')

local this = {
    config = {
        ---@type boolean
        enabled = configService.get('teams:enabled') or configService.get('relations:enabled')
    },
    service = require('prototypes.modules.offers.service'),
    commands = require('prototypes.modules.offers.commands'),
    events = require('prototypes.modules.offers.events')
}

local function on_any()
    if this.config.enabled then
        this.commands.init()
    end
end

function this.on_init() on_any() end

function this.on_load() on_any() end

return this
