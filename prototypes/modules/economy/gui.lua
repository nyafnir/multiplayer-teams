local this = {}

function this.showShopBuyUI(player, entity)
    local player_gui = player.gui.screen
    if player_gui['shop-gui'] ~= nil then
        player.opened = player_gui['shop-gui']
        return
    end
    if entity.name == "shop-buy" then

        local options = {}
        options.selectedEntity = player.selected

        local gui = player.gui.screen.add({
            type = "frame",
            name = "shop-gui",
            direction = "vertical"
        })

        gui.auto_center = true

        Utils.styles.addTitlebar(gui, "Продажа", configService.config.prefix .. '-x-button')

        local contentFrame = gui.add({
            type = "flow",
            name = "content_frame",
            direction = "horizontal"
        })

        local function drawShopGUI()
            Utils.styles.addInventory(contentFrame, player.get_main_inventory())
            local separator = '='

            local shopGUI = contentFrame.add({
                type = 'frame',
                direction = "vertical",
                name = 'shop-gui',
                style = 'entity_frame'
            }).add({
                type = 'frame',
                direction = "vertical",
                style = 'deep_frame_in_shallow_frame'
            })
            local shopInventory = {}
            local function initInventoryShop()

                local inventory = entity.get_inventory(defines.inventory.chest)
                shopInventory = {}
                local itemsWithEquipment = 0
                for i = 1, #inventory do
                    local item = inventory[i]
                    if item.valid_for_read then
                        local price = economyModule.service.getEconomy().prices[item.name]
                        if item.grid then
                            local gridOfEquipment = item.grid.get_contents()
                            local equipmentPrice = 0;
                            for equipmentName, count in pairs(gridOfEquipment) do
                                equipmentPrice = equipmentPrice +
                                    economyModule.service.getEconomy().prices[equipmentName] *
                                    count
                            end
                            shopInventory[item.name .. separator ..
                                itemsWithEquipment] = {
                                name = item.name,
                                price = price + equipmentPrice,
                                equipment = gridOfEquipment
                            }
                            itemsWithEquipment = itemsWithEquipment + 1
                        else
                            if shopInventory[item.name] then
                                shopInventory[item.name].count =
                                shopInventory[item.name].count + item.count
                            else
                                shopInventory[item.name] = {
                                    name = item.name,
                                    price = price,
                                    count = item.count
                                }
                            end
                        end
                    end
                end
            end

            initInventoryShop()

            local framePreview = shopGUI.add({
                type = "empty-widget",
                style = "wide_entity_button"
            })

            local entityPreview = framePreview.add({
                type = "entity-preview"
            })

            entityPreview.style.width = 440
            entityPreview.style.height = 148
            entityPreview.visible = true
            entityPreview.entity = options.selectedEntity

            local orderContent = contentFrame['shop-gui'].add({
                type = 'frame',
                direction = "vertical"
            })

            orderContent.add {
                type = "frame",
                name = "button_frame",
                direction = "horizontal",
                style = configService.config.prefix .. "-deep-frame"
            }

            orderContent.style.width = 440
            local buyControl = orderContent.add({
                type = 'flow',
                direction = "horizontal"
            })
            local function getFirstItem()
                if #shopInventory > 0 then
                    for _, item in pairs(shopInventory) do
                        return item.name
                    end
                end
                return ''
            end

            local function isHasEquipment(name)
                local resultTable = Utils.string.split(name, separator)
                return #resultTable > 1
            end

            -- таблица с итемами
            local function drawInventoryShop()
                if orderContent['button_frame'] ~= nil then
                    orderContent['button_frame'].clear()
                end

                local selectedItem = options.selectedItem or ''

                if selectedItem == '' then
                    selectedItem = getFirstItem()
                end

                local button_table = orderContent['button_frame'].add {
                    type = "table",
                    name = "button_table",
                    column_count = 10,
                    style = "filter_slot_table"
                }
                for key, item in pairs(shopInventory) do
                    local buttonStyle = (key == selectedItem) and
                        "yellow_slot_button" or
                        "recipe_slot_button"
                    local equipment = ""
                    if item.equipment ~= nil then
                        for equipmentName, count in pairs(item.equipment) do
                            equipment = {
                                "", equipment, "\n",
                                { "equipment-name." .. equipmentName }, ": ",
                                count
                            }
                        end
                    end
                    local btn = button_table.add {
                        type = "sprite-button",
                        sprite = ("item/" .. item.name),
                        style = buttonStyle,
                        tags = {
                            action = configService.config.prefix .. "-select_item_for_buy",
                            itemName = key
                        },
                        tooltip = {
                            "", { "item-name." .. item.name },
                            '\nСтоимость: ', item.price, ' €$',
                            equipment
                        }
                    }
                    if isHasEquipment(key) then
                        btn.tags.equipment = item.equipment
                    else
                        btn.number = item.count
                    end
                end
            end

            drawInventoryShop()

            local function drawOrderController()

                if buyControl ~= nil then buyControl.clear() end
                local selectedItem = options.selectedItem or ''

                if selectedItem == '' then
                    selectedItem = getFirstItem()
                end

                buyControl.add {
                    type = 'sprite-button',
                    name = 'selectedItem',
                    style = 'recipe_slot_button'
                }
                if selectedItem ~= '' then
                    buyControl['selectedItem'].sprite = "item/" ..
                        shopInventory[selectedItem]
                        .name
                end

                local controls_slider = buyControl.add {
                    type = "slider",
                    name = configService.config.prefix .. "-controls_slider",
                    value = math.min(options.count or 1),
                    minimum_value = 0,
                    maximum_value = selectedItem ~= '' and
                        shopInventory[selectedItem].count or 1,
                    style = "notched_slider"
                }
                controls_slider.enabled =
                selectedItem ~= '' and shopInventory[selectedItem].count or
                    1 > 1

                local controls_textfield = buyControl.add {
                    type = "textfield",
                    name = configService.config.prefix .. "-controls_textfield",
                    text = tostring(options.count or 1),
                    numeric = true,
                    allow_decimal = false,
                    allow_negative = false,
                    style = configService.config.prefix .. "-controls-textfield"
                }

                controls_textfield.enabled =
                selectedItem ~= '' and shopInventory[selectedItem].count or
                    1 > 1

                buyControl.add({
                    type = 'button',
                    style = 'confirm_button',
                    name = configService.config.prefix .. "-controls-button",
                    caption = 'Купить',
                    enabled = selectedItem ~= '' and options.count > 0
                })

                script.on_event(defines.events.on_gui_value_changed,
                    function(event)
                        if event.element.name == configService.config.prefix .. "-controls_slider" then
                            controls_textfield.text =
                            tostring(event.element.slider_value)
                        end
                    end)

                script.on_event(defines.events.on_gui_text_changed,
                    function(event)
                        if event.element.name == configService.config.prefix .. "-controls_textfield" then
                            local value = math.min(
                                tonumber(event.element.text) or 0,
                                shopInventory[selectedItem].count or 1)
                            controls_slider.slider_value = value
                            controls_textfield.text = tostring(value)
                        end
                    end)

                script.on_event(defines.events.on_player_main_inventory_changed, function(_)
                    if player_gui['shop-gui'] ~= nil then
                        drawShopGUI()
                    end
                end)

            end

            drawOrderController()
            player.opened = gui

            script.on_event(defines.events.on_gui_click, function(event)
                local element = event.element
                if not element.valid then return end
                if element.tags.action == configService.config.prefix .. "-select_item_for_buy" then
                    local selectedItem = element.tags.itemName
                    -- player[configService.config.prefix]['shop-buy'].selectedItem = selectedItem
                    options.count = 1
                    options.selectedItem = selectedItem
                    drawInventoryShop()
                    drawOrderController()
                    return
                end

                if element.name == configService.config.prefix .. '-x-button' then
                    gui.destroy()
                end
            end)

            script.on_event(configService.config.prefix .. "_E_closeGUI", function(_)
                gui.destroy()
            end)
            script.on_event(configService.config.prefix .. "_ESCAPE_closeGUI", function(_)
                gui.destroy()
            end)

        end

        drawShopGUI()
    end
end

return this
