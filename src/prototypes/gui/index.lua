local this = {}

function this.start()
    script.on_event(defines.events.on_player_created, function(event)
        if getConfig('gui:enable') == true then
            this.addMainButton(getPlayerById(event.player_index))
        end
    end)

    script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
        if event.setting == 'multiplayer-teams:gui:enable' then
            if getConfig('gui:enable') == true then
                this.addMainButtons()
            else
                this.removeMainButtons()
            end
        end
    end)
end

function this.addMainButton(player)
    if player.gui.top.mod_button ~= nil then
        return
    end

    --- https://lua-api.factorio.com/latest/LuaGuiElement.html
    player.gui.top.add({
        name = "mod_button",
        type = 'button',
        caption = {'gui.main.button-caption'}, --- LocalisedString
        style = 'main_button',
        tooltip = {'gui.main.button-tooltip'}, --- LocalisedString
        enabled = true,
        visible = true,
        ignored_by_interaction = false, -- Запретить взаимодествие
        tags = {}, --- {a = 1, b = true, c = "three", d = {e = "f"}}
        index = nil, --- Место в родительском элементе, в которое должен 
        --- вставляться дочерний элемент. По умолчанию дочерний элемент
        --- будет добавлен в конец.
        anchor = nil --- Где разместить дочерний элемент в относительном элементе.
    })
end

function this.addMainButtons()
    for _, player in pairs(game.players) do
        this.addMainButton(player)
    end
end

function this.removeMainButtons()
    for _, player in pairs(game.players) do
        player.gui.top.mod_button.destroy()
    end
end

return this
