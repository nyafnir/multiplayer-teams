--- настройки недоступны из модуля на этапе инициализации, поэтому нужен прямой импорт
local config = require('prototypes.modules.relations.config')

script.on_nth_tick(config.offer.timeout.ticks, function()
    local list = relations.store.offers.getAll()
    if not next(list) then
        return
    end

    for ownerId, offer in pairs(list) do
        if offer.expiredAt <= game.ticks_played then
            relations.store.offers.remove(ownerId)
        end
    end
end)
