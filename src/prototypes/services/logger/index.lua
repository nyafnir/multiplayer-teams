--- Сервис для вывода информации в чат
LoggerService = {}

require('prototypes.utils.string')

--- Написать сообщение цели (игрок, команда или не указать, то значит в глобальный чат).
--- - Ничего не отправит, если entity не указан и глобальной `game` не существует).
--- @param message string | table | nil
--- @param entity nil | LuaPlayer | LuaForce | ForceIdentification Здесь ожидается объект
--- @param color Color | nil
function LoggerService.chat(message, color, entity)
    local target = entity or game

    if target == nil or type(target) ~= 'table' then
        return
    end

    local messageType = { 'mt.logger.message-type.global' }
    if target.object_name == 'LuaPlayer' then
        messageType = { 'mt.logger.message-type.player' }
        color = color or ColorUtils.colors.pink
    else
        if target.object_name == 'LuaForce' then
            messageType = { 'mt.logger.message-type.force' }
            color = color or target.color
        end
    end

    local title = ConfigService.getValue('logger:prefix:title', false)
    local prefix = title == '' and title or '[' .. title .. ']' .. ' '
    local type = { '', '[',
        messageType,
        ']' .. ' ' }
    color = color or ConfigService.getValue('logger:prefix:color', false)

    target.print(
        { '',
            prefix,
            type,
            message
        },
        color
    )
end

--- Написать сообщение всем игрокам у кого включен дебаг режим.
--- Учитывает цвет выставленный в настройках каждого игрока.
--- Возвращает то, что принял.
--- @param data any
function LoggerService.debug(data)
    for index, player in pairs(game.players) do
        if ConfigService.getValueFor('logger:debug:enabled', false, index) then
            local title = ConfigService.getValueFor('logger:debug:prefix:title', false, index)
            local prefix = title == '' and title or '[' .. title .. ']' .. ' '
            local message = StringUtils.convertAnyToString(data)
            local color = ConfigService.getValueFor('logger:debug:prefix:color', false, index)

            --- @cast color Color
            player.print({ '', prefix, message }, color)
        end
    end

    return data
end
