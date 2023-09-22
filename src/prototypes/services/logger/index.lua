LoggerService = {}

require('prototypes.utils.string')

--- Написать сообщение в общий игровой чат.
--- Если "game" нет, то ничего не отправит.
--- Возвращает то, что принял.
--- @generic T string | nil
--- @param message T
--- @return T
function LoggerService.chat(message)
    if game then
        local title = ConfigService.getValue('logger:prefix:title', false)
        local prefix = title == '' and title or '[' .. title .. ']' .. ' '
        local color = ConfigService.getValue('logger:prefix:color', false)

        --- @cast color Color
        game.print(prefix .. message, color)
    end

    return message
end

--- Написать сообщение всем игрокам у кого включен дебаг режим.
--- Учитывает цвет выставленный в настройках каждого игрока.
--- Возвращает то, что принял.
--- @generic T
--- @param data T
--- @return T
function LoggerService.debug(data)
    for index, player in pairs(game.players) do
        if ConfigService.getValueFor('logger:debug:enabled', false, index) then
            local title = ConfigService.getValueFor('logger:debug:prefix:title', false, index)
            local prefix = title == '' and title or '[' .. title .. ']' .. ' '
            local str = StringUtils.convertAnyToString(data)
            local color = ConfigService.getValueFor('logger:debug:prefix:color', false, index)

            --- @cast color Color
            player.print(prefix .. str, color)
        end
    end

    return data
end
