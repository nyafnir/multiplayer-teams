local this = {
    config = {
        enable = getConfig('logger:enable'),
        prefix = getConfig('logger:prefix')
    }
}

---Вывести сообщение в общий игровой чат.
---Возвращает то, что принял.
---@param message string
---@return message
function this.chat(message)
    if message == nil then return message end

    --- game chat
    if game then game.print(message) end

    return message
end

function this.all(message) return this.chat(message) end

---Вывести сообщение в лог-файл.
---Возвращает то, что принял.
---@param message string
---@return message
function this.file(message)
    if message == nil then return message end

    --- factorio-current.log
    log(message)

    return message
end

---Вывести сообщение во все места куда можно.
---Возвращает то, что принял.
---@param data any
---@return data
function this.log(data)
    local message = this.config.prefix .. ' ' .. convertAnyToString(data)
    this.chat(message)
    this.file(message)

    return data
end

---Вывести сообщение с проверкой на включение режима отладки.
---Возвращает то, что принял.
---@param data any
---@return data
function this.debug(data)
    if data == nil then return data end
    if this.config.enable ~= true then return data end

    return this.log(data)
end

return this
