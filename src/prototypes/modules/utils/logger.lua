--- [Метод] Вывести сообщение в чат (вывод отключается через настройки)
function logger(text)
    if getConfig('logger-enable') == true then
        game.print(getConfig('logger-prefix') .. text)
    end
end
