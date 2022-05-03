--- [Метод] Вывести сообщение в чат (вывод отключается через настройки)
function logger(text)
    if getConfig('logger:enable') == true then
        game.print(getConfig('logger:prefix') .. text) -- игровой чат
        print(getConfig('logger:prefix') .. text) -- TODO: куда записывается этот лог?
    end
end
