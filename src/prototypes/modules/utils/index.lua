--- [Метод] Получить значение настройки без указания префикса
function getConfig(name)
    -- if player ~= nil then
    --     local runtime_per_user = player.mod_settings['multiplayer-teams:' .. name]
    --     if runtime_per_user ~= nil then
    --         return runtime_per_user.value
    --     else
    --         return nil
    --     end
    -- end

    local startup = settings.startup['multiplayer-teams:' .. name]
    if startup ~= nil then
        return startup.value
    end

    local runtime_global = settings.global['multiplayer-teams:' .. name]
    if runtime_global ~= nil then
        return runtime_global.value
    end

    return nil
end

--- [Метод] Выдать предмет игроку
function giveItemToPlayer(playerId, itemName, amount)
    local player = game.players[playerId]
    player.insert({
        name = itemName,
        count = amount
    })
end

-- [Метод] Сделать запись отладки в чат
function logger(text)
    if getConfig('logger-enable') == true then
        game.print(getConfig('logger-prefix') .. text)
    end
end
