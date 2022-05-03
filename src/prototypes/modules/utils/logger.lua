--- [Метод] Вывести сообщение в чат (вывод отключается через настройки)
function logger(text)
    if getConfig('logger:enable') ~= true then
        return
    end

    if text == nil then
        text = 'nil'
    end

    local record = getConfig('logger:prefix') .. serpent.block(text)

    if game ~= nil then
        game.print(record) -- chat
    end
    print(record) -- console
    log(record) -- factorio-current.log

end

function tableToString(table)
    return serpent.block(table)
end
