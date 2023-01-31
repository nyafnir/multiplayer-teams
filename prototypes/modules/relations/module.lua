local this = {
    config = {
        ---@type boolean
        enabled = configService.get('relations:enabled'),
        offer = {
            timeout = {
                ---@type number
                minutes = configService.get('relations:offer-timeout'),
                ---@type number
                ticks = Utils.time.convertMinutesToTicks(configService.get('relations:offer-timeout'))
            }
        },
        friendlyFire = {
            enabled = configService.get('relations:friendly-fire:enabled'),
        }
    },
    service = require('prototypes.modules.relations.service'),
    commands = require('prototypes.modules.relations.commands'),
    events = require('prototypes.modules.relations.events')
}

local function on_any()
    if this.config.enabled then
        this.commands.init()
    end
end

function this.on_init() on_any() end

function this.on_load() on_any() end

return this
