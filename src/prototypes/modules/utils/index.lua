-- Файл вспомогательных функций

--- [Метод] Получить значение настройки без указания префикса
function getConfig(name)
    return settings.startup['multiplayer-teams:' .. name].value
end

--- [Метод] Выдать предмет игроку
function giveItemToPlayer(playerId, itemName, amount)
    local player = game.players[playerId]
    player.insert({name=itemName, count=amount})
end
