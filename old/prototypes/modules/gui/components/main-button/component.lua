local this = {}

---Добавляет кнопку (если её нет) игроку на экран
function this.addFor(player)
    if player.gui.top[configService.getKey('gui:buttons:main')] ~= nil then return end

    --- https://lua-api.factorio.com/latest/LuaGuiElement.html
    player.gui.top.add({
        name = configService.getKey('gui:buttons:main'),
        type = 'button',
        caption = { configService.getKey('gui:buttons.main-caption') },
        style = 'main_button',
        tooltip = { configService.getKey('gui:buttons.main-tooltip') },
        enabled = true,
        visible = true,
        --- Запретить взаимодествие
        ignored_by_interaction = false,
        --- {a = 1, b = true, c = "three", d = {e = "f"}}
        tags = {},
        --- Место в родительском элементе, в которое должен
        --- вставляться дочерний элемент. По умолчанию дочерний элемент
        --- будет добавлен в конец.
        index = nil,
        --- Где разместить дочерний элемент в относительном элементе.
        anchor = nil
    })
end

function this.addForAll()
    for _, player in pairs(game.players) do this.addFor(player) end
end

function this.removeForAll()
    for _, player in pairs(game.players) do
        ---Проверяем, что кнопка есть и только тогда удаляем её
        local button = player.gui.top[configService.getKey('gui:buttons:main')]
        if button ~= nil then
            button.destroy()
        end
    end
end

return this
