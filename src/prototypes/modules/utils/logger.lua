--- [Метод] Вывести сообщение в чат (вывод отключается через настройки)
function logger(text)
    if getConfig('logger:enable') == true then
        if text == nil then
            text = 'nil'
        end

        game.print(getConfig('logger:prefix') .. text) -- игровой чат
        print(getConfig('logger:prefix') .. text) -- TODO: куда записывается этот лог?
    end
end
