local this = {}

local function on_any() end

function this.on_init() on_any() end

function this.on_load() on_any() end

return this
