local this = {
    config = {
        ---@type boolean
        enabled = configService.get('logger:enabled'),
        ---@type string
        prefix = configService.get('logger:prefix')
    }
}

---Написать сообщение в общий игровой чат.
---Если "game" нет, то ничего не отправит.
---Возвращает то, что принял.
---@param message string | nil
---@return string | nil
function this.chat(message)
    if game then
        game.print(message)
    end
    return message
end

---Написать сообщение во все места куда можно, но
---с проверкой на включение режима отладки.
---Возвращает то, что принял.
---@param data any
---@return any
function this.debug(data)
    if this.config.enabled ~= true then
        return data
    end

    local message = this.config.prefix .. ' ' .. Utils.string.convertAnyToString(data)

    return this.chat(message)
end

---Написать сообщение в лог-файл.
---Возвращает то, что принял.
---@param message string | nil
---@return string | nil
function this.file(message)
    log(message) --- factorio-current.log
    return message
end

return this
