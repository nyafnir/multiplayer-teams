GuiService = {}

--- @private
--- @param player LuaPlayer
function GuiService.onPlayerJoinedGame(player)
    --- https://lua-api.factorio.com/latest/LuaGuiElement.html
    player.gui.top.add({
        name = 'mt.gui.buttons.main',
        type = 'button',
        style = 'mt.main.button',
        caption = { 'mt.gui.buttons.main.caption' },
        tooltip = { 'mt.gui.buttons.main.tooltip' },
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
        --- Где разместить дочерний элемент в относительном элементе
        anchor = nil
    })
end
