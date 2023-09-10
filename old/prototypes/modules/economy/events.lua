script.on_event(defines.events.on_force_created, function(force)
    ---TODO: удалить, это условие никогда не произойдёт
    if economyModule.service.getEconomy().balances[force.name] ~= nil then
        return
    end

    economyModule.service.getEconomy().balances[force.name] = {
        coins = 0,
        sum = 0
    }

    loggerService.debug('Для команды с именем' .. force.name ..
        ' создан счет в банке:')
    loggerService.debug(economyModule.service.getEconomy().balances[force.name])
end)

local economyGui = require('prototypes.modules.economy.gui')
script.on_event(defines.events.on_gui_opened, function(event)
    if event.entity == nil then return end
    -- тут добавить проверку что фракция не соответствует игроку, тогда показываем магазин иначе склад!
    if event.entity.name ~= 'shop-buy' then return end
    local player = playerService.getById(event.player_index)
    if not player or not player.valid then return end
    if player.force.index == event.entity.last_user.force.index then return end
    economyGui.showShopBuyUI(player, event.entity)
end)
