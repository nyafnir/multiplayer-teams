require("prototypes.modules.economy.ttl")
mod_gui = require("mod-gui")
local prefix = 'multiplayer-teams'

local Styles = require('prototypes.modules.utils.styles')
-- вода беспланая
-- magic number наценка за производство
local EXTRA_CHARGE = 1
-- ore magic изначальная цена руды
local ORE_PRICE = 1
-- fluid magic коээфицент для жидкостей
local FLUID_COEFFICIENT = 0.05

---при первом запуске проинициализировать цену продукции
local function initPrices(force)
    local function checkReceipt(name)
        if global.economy.prices[name] then
            return global.economy.prices[name]
        end
        local receipt = force.recipes[name]
        if receipt == nil then
            global.economy.prices[name] = ORE_PRICE
            return ORE_PRICE
        end

        local price = 0

        for _, ingredient in pairs(receipt.ingredients) do
            if ingredient.type == 'fluid' then
                price = price + ingredient.amount * FLUID_COEFFICIENT
            else
                price = price + checkReceipt(ingredient.name) *
                            ingredient.amount
            end
        end

        local countProducts = 0

        for _, product in pairs(receipt.products) do
            countProducts = countProducts + product.amount
        end
        local result = math.ceil(price / countProducts) + EXTRA_CHARGE
        global.economy.prices[name] = result
        return result
    end

    for item, _ in pairs(game.item_prototypes) do checkReceipt(item) end

end

local function setCash(playerName, cash)
    global.economy.balances[playerName].coins = cash
end

local function popCash(playerName, cash)
    if cash > global.economy.balances[playerName].coins then return false end
    global.economy.balances[playerName].coins =
        global.economy.balances[playerName].coins - cash
    return true
end

---обмен
-- trade(teamId1, teamId2, products)

---нельзя положить сломанный предмет на продажу или для задания
-- checkBrokenItem()

---проверка на валидность здания (существует ли еще)
-- checkValidBuild()

---кладем предметы в маркет и достаем ?авторазгрузка/погрузка манипуляторами?
-- pushItemsInMarket()
-- popItemsFromMarket()
---guiMarket

local function showShopBuyUI(player, entity)

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

        Styles.addTitlebar(gui, "Продажа", 'my-mod-x-button')

        local contentFrame = gui.add({
            type = "flow",
            name = "content_frame",
            direction = "horizontal"
        })

        local function drawShopGUI()
            Styles.addInventory(contentFrame, player.get_main_inventory())
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
                        local price = global.economy.prices[item.name]
                        if item.grid then
                            local gridOfEquipment = item.grid.get_contents()
                            local equipmentPrice = 0;
                            for equipmentName, count in pairs(gridOfEquipment) do
                                equipmentPrice = equipmentPrice +
                                                     global.economy.prices[equipmentName] *
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
                style = prefix .. "-deep-frame"
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
                                {"equipment-name." .. equipmentName}, ": ",
                                count
                            }
                        end
                    end
                    local btn = button_table.add {
                        type = "sprite-button",
                        sprite = ("item/" .. item.name),
                        style = buttonStyle,
                        tags = {
                            action = prefix .. "-select_item_for_buy",
                            itemName = key
                        },
                        tooltip = {
                            "", {"item-name." .. item.name},
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
                    name = prefix .. "-controls_slider",
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
                    name = prefix .. "-controls_textfield",
                    text = tostring(options.count or 1),
                    numeric = true,
                    allow_decimal = false,
                    allow_negative = false,
                    style = prefix .. "-controls-textfield"
                }

                controls_textfield.enabled =
                    selectedItem ~= '' and shopInventory[selectedItem].count or
                        1 > 1

                buyControl.add({
                    type = 'button',
                    style = 'confirm_button',
                    name = prefix .. "-controls-button",
                    caption = 'Купить',
                    enabled = selectedItem ~= '' and options.count > 0
                })

                script.on_event(defines.events.on_gui_value_changed,
                                function(event)
                    if event.element.name == prefix .. "-controls_slider" then
                        controls_textfield.text =
                            tostring(event.element.slider_value)
                    end
                end)

                script.on_event(defines.events.on_gui_text_changed,
                                function(event)
                    if event.element.name == prefix .. "-controls_textfield" then
                        local value = math.min(
                                          tonumber(event.element.text) or 0,
                                          shopInventory[selectedItem].count or 1)
                        controls_slider.slider_value = value
                        controls_textfield.text = tostring(value)
                    end
                end)

                script.on_event(defines.events.on_player_main_inventory_changed,
                                function(event)
                    if player_gui['shop-gui'] ~= nil then
                        drawShopGUI()
                    end
                end)

            end

            drawOrderController()
            player.opened = gui

            -- player.print(serpent.dump(shopInventory))
            script.on_event(defines.events.on_gui_click, function(event)
                local element = event.element
                if not element.valid then return end
                if element.tags.action == prefix .. "-select_item_for_buy" then
                    local selectedItem = element.tags.itemName
                    -- player[prefix]['shop-buy'].selectedItem = selectedItem
                    options.count = 1
                    options.selectedItem = selectedItem
                    drawInventoryShop()
                    drawOrderController()
                    return
                end

                if element.name == "my-mod-x-button" then
                    element.parent.parent.destroy()
                    return
                end
            end)

        end

        drawShopGUI()

    end
end

local function shopGUI()
    script.on_event(defines.events.on_gui_opened, function(event)
        if event.entity == nil then return end
        -- тут добавить проверку что фракция не соответствует игроку, тогда показываем магазин иначе склад!
        if event.entity.name == 'shop-buy' then
            local player = game.players[event.player_index]
            if not player or not player.valid then return end
            showShopBuyUI(player, event.entity)
        end
    end)

    script.on_event(defines.events.on_gui_click, function(event)
        local guiName = event.element.name
        if guiName == "my-mod-x-button" then
            event.element.parent.parent.destroy()
            return
        end
    end)
end

function initModuleEconomy()
    global.economy = {
        balances = {},
        prices = {}
    }
    initPrices(teams.store.forces.getDefault())
    -- global.economy.balances[player.force.index] = {coins = 0}

    -- shopGUI()
end

script.on_event(defines.events.on_player_joined_game, function(event)
    local player = getPlayerById(event.player_index)
    logger('Игрок ' .. player.name ..
               ' присоединился к игре')
    if global.economy.balances[event.player_index] ~= nil then return end
    global.economy.balances[event.player_index] = {
        coins = 0
    }
end)