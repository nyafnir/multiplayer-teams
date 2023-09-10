require('prototypes.modules.teams.types')

local this = {
    config = {
        ---@type boolean
        enabled = configService.get('teams:enabled'),
        invite = {
            timeout = {
                ---@type number
                minutes = configService.get('teams:invite-timeout'),
                ---@type number
                ticks = Utils.time.convertMinutesToTicks(configService.get('teams:invite-timeout'))
            }
        }
    },
    service = require('prototypes.modules.teams.service'),
    commands = require('prototypes.modules.teams.commands'),
    events = require('prototypes.modules.teams.events')
}

local function on_any()
    if this.config.enabled then
        this.commands.init()
    end
end

function this.on_init() on_any() end

function this.on_load() on_any() end

return this
