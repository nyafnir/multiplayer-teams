--- Настройки недоступны из модуля на этапе инициализации, поэтому нужен прямой импорт
local config = require('prototypes.modules.teams.config')

script.on_nth_tick(config.invite.timeout.ticks, function()
    local list = teams.store.invites.getAll()
    if not next(list) then return end

    for playerId, invite in pairs(list) do
        if invite.expiredAt <= game.ticks_played then
            teams.store.invites.remove(playerId)
        end
    end
end)
