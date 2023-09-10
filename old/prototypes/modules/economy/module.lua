local this = {
    config = {
        ---@type boolean
        enabled = configService.get('economy:enabled'),
        ---@type number
        timeSalary = configService.get('economy:salary-interval'),
        ---@type number
        fluidCoefficient = configService.get('economy:fluid-coefficient'),
        ---@type number
        priceOre = configService.get('economy:price-ore'),
        ---@type number
        priceProduction = configService.get('economy:price-production')
    },
    service = require('prototypes.modules.economy.service'),
    -- events = require('prototypes.modules.economy.events'),
    -- ttl = require("prototypes.modules.economy.ttl")
}

require("mod-gui")
require("prototypes.modules.economy.ttl")
require("prototypes.modules.economy.events")

local function on_any()
    -- if this.config.enabled then
    --     this.commands.init()
    -- end
end

function this.on_init() on_any() end

function this.on_load() on_any() end

return this
