local this = {}

function this.addTitlebar(gui, caption, close_button_name)
    local titlebar = gui.add {
        type = "flow"
    }
    titlebar.drag_target = gui
    titlebar.add {
        type = "label",
        style = "frame_title",
        caption = caption,
        ignored_by_interaction = true
    }
    local filler = titlebar.add {
        type = "empty-widget",
        style = "draggable_space",
        ignored_by_interaction = true
    }
    filler.style.height = 24
    filler.style.horizontally_stretchable = true
    titlebar.add {
        type = "sprite-button",
        name = close_button_name,
        style = "frame_action_button",
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
        tooltip = { "gui.close-instruction" }
    }
end

function this.addInventory(gui, inventory)
    if gui ~= nil then
        gui.clear()
    end

    local playerGUI = gui.add({
        type = "frame",
        name = "player-scroll-pane",
        direction = "vertical",
        style = 'inside_shallow_frame_with_padding'
    })

    playerGUI.add({
        type = "label",
        name = 'player',
        caption = "Персонаж"
    })

    local slotTable = playerGUI.add({
        type = "table",
        name = "button_table",
        column_count = 10,
        style = "slot_table"
    })
    for i = 1, #inventory do
        local item = inventory[i]

        if item.valid_for_read then
            local b = slotTable.add {
                type = "choose-elem-button",
                elem_type = 'item',
                elem_value = item.name,
                style = "slot",
                item = item.name
            }
            b.locked = true
            if not item.item_number then
                local count = item.count
                if count > 1000 then
                    local tCount = math.floor(item.count / 100)
                    if tCount > 100 then
                        count = tostring(math.floor(tCount / 10)) .. 'к'
                    else
                        count = tostring(tCount / 10) .. 'к'
                    end
                end
                b.add({
                    type = 'label',
                    caption = count,
                    style = 'icon_count',
                    ignored_by_interaction = true
                })
            end
        else
            local b = slotTable.add {
                type = "sprite-button",
                style = "slot"
            }
            -- b.add({})
        end
    end

end

return this
