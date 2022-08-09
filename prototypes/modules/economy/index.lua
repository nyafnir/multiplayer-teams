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
-- врмея ЗП в минутах
local TIME_SALARY = 2
-- 1 секунда = 60 тиков, 1 минута = 60 тиков * 60 секунд
local ticksToSalary = 60 * 60

---при первом запуске проинициализировать цену продукции
local function initPrices(player)
    local function checkReceipt(name)
        if global.economy.prices[name] then
            return global.economy.prices[name]
        end

        local receipt = player.force.recipes[name]
        if receipt == nil then
            global.economy.prices[name] = ORE_PRICE
            return ORE_PRICE
        end

        local price = 0

        for _, ingredient in pairs(receipt.ingredients) do
            if ingredient.type == 'fluid' then
                price = price + ingredient.amount * FLUID_COEFFICIENT
            else
                price = price + checkReceipt(ingredient.name) * ingredient.amount
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

    for item, _ in pairs(game.item_prototypes) do
        local result = checkReceipt(item)
    end

end

local function setCash(playerName, cash)
    global.economy.balances[playerName].coins = cash
end

local function addCash(playerName, cash)
    global.economy.balances[playerName].coins = global.economy.balances[playerName].coins + cash
end

local function popCash(playerName, cash)
    if cash > global.economy.balances[playerName].coins then
        return false
    end
    global.economy.balances[playerName].coins = global.economy.balances[playerName].coins - cash
    return true
end

local function accamulateSalary(player)
    local sum = 0
    for item, _ in pairs(game.fluid_prototypes) do
        if item == 'water' then
            goto continue
        end
        local icf, ocf = 0, 0
        icf = player.force.fluid_production_statistics.get_flow_count({
            name = item,
            input = true,
            precision_index = defines.flow_precision_index.one_minute,
            count = true
        })
        ocf = player.force.fluid_production_statistics.get_flow_count({
            name = item,
            input = false,
            precision_index = defines.flow_precision_index.one_minute,
            count = true
        })

        if icf > 0 then
            sum = sum + math.floor(icf * FLUID_COEFFICIENT)
        end

        if ocf > 0 then
            sum = sum - math.floor(ocf * FLUID_COEFFICIENT)
        end
        ::continue::
    end
    for item, _ in pairs(game.item_prototypes) do
        local ic, oc = 0, 0
        ic = player.force.item_production_statistics.get_flow_count({
            name = item,
            input = true,
            precision_index = defines.flow_precision_index.one_minute,
            count = true
        })
        local fic = player.force.item_production_statistics.get_flow_count({
            name = item,
            input = true,
            precision_index = defines.flow_precision_index.one_minute,
            count = false
        })
        oc = player.force.item_production_statistics.get_flow_count({
            name = item,
            input = false,
            precision_index = defines.flow_precision_index.one_minute,
            count = true
        })
        if ic > 0 then
            sum = sum + ic * global.economy.prices[item]
        end
        if oc > 0 then
            sum = sum - oc * global.economy.prices[item]
        end
    end
    return sum
end

local function salary(player)
    local iteration, sum = 0, 0
    script.on_nth_tick(ticksToSalary, function(event)
        iteration = iteration + 1
        sum = sum + accamulateSalary(player)
        if iteration == TIME_SALARY then
            if sum > 0 then
                addCash(player.name, sum)
                player.print('Начисление зп в размере ' .. sum .. ' всего на счету: ' ..
                                 global.economy.balances[player.name].coins)
            else
                player.print(
                    'Корпарация вами не довольна. В этот раз вы потратили ресурсов больше чем добыли, поэтому деньги не будут начислены.\nВсего на счету: ' ..
                        global.economy.balances[player.name].coins)
            end
            iteration, sum = 0, 0
        end
    end)

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
                local separator = '='
                for i = 1, #inventory do
                    local item = inventory[i]
                    if item.valid_for_read then
                        local price = global.economy.prices[item.name]
                        if item.grid then
                            --
                            -- надо проверить grid и прибавить к стоимости
                            -- get_contents --Get counts of all equipment in this grid. //dictionary[string → uint]
                            -- equipment --All the equipment in this grid //array[LuaEquipment]
                            -- put --Insert an equipment into the grid. //{name=…, position=…, by_player=…} => LuaEquipment?
                            --
                            shopInventory[item.name .. separator .. itemsWithEquipment] = {
                                name = item.name,
                                price = price,
                                equipment = {} -- item.equipment_grid --здесь мб просто массив будет а потом уже конвертироват его при покупке
                            }
                            itemsWithEquipment = itemsWithEquipment + 1
                        else
                            if shopInventory[item.name] then
                                shopInventory[item.name].count = shopInventory[item.name].count + item.count
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
                local resultTable = split(name, separator)
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
                    local buttonStyle = (key == selectedItem) and "yellow_slot_button" or "recipe_slot_button"
                    local btn = button_table.add {
                        type = "sprite-button",
                        sprite = ("item/" .. item.name),
                        style = buttonStyle,
                        tags = {
                            action = prefix .. "-select_item_for_buy",
                            itemName = key
                        },
                        tooltip = 'Стоимость: ' .. item.price
                    }
                    if isHasEquipment(key) then
                        btn.tags.equipment = item.equipment
                    else
                        btn.number = item.count
                    end
                end
            end

            drawInventoryShop()

            function drawOrderController()
                
                if buyControl ~= nil then
                    buyControl.clear()
                end
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
                    buyControl['selectedItem'].sprite = "item/" .. shopInventory[selectedItem].name
                end

                local controls_slider = buyControl.add {
                    type = "slider",
                    name = prefix .. "-controls_slider",
                    value = math.min(options.count or 0),
                    minimum_value = 0,
                    maximum_value = selectedItem ~= '' and shopInventory[selectedItem].count or 1,
                    style = "notched_slider"
                }
                controls_slider.enabled = selectedItem ~= ''

                local controls_textfield = buyControl.add {
                    type = "textfield",
                    name = prefix .. "-controls_textfield",
                    text = tostring(options.count or 0),
                    numeric = true,
                    allow_decimal = false,
                    allow_negative = false,
                    style = prefix .. "-controls-textfield"
                }

                controls_textfield.enabled = selectedItem ~= ''

                buyControl.add({
                    type = 'button',
                    style = 'confirm_button',
                    name = prefix .. "-controls-button",
                    caption = 'Купить',
                    enabled = selectedItem ~= ''
                })

                script.on_event(defines.events.on_gui_value_changed, function(event)
                    if event.element.name == prefix .. "-controls_slider" then
                        controls_textfield.text = tostring(event.element.slider_value)
                    end
                end)

                script.on_event(defines.events.on_gui_text_changed, function(event)
                    if event.element.name == prefix .. "-controls_textfield" then
                        local value =
                            math.min(tonumber(event.element.text) or 0, shopInventory[selectedItem].count or 1)
                        controls_slider.slider_value = value
                        controls_textfield.text = tostring(value)
                    end
                end)

                script.on_event(defines.events.on_player_main_inventory_changed, function(event)
                    if player_gui['shop-gui'] ~= nil then
                        drawShopGUI()
                    end
                end)

            end
            drawOrderController()
            player.opened = gui

        end
        drawShopGUI()
        -- player.print(serpent.dump(shopInventory))

        script.on_event(defines.events.on_gui_click, function(event)
            local element = event.element
            if not element.valid then
                return
            end
            if element.tags.action == prefix .. "-select_item_for_buy" then
                local selectedItem = element.tags.itemName
                -- player[prefix]['shop-buy'].selectedItem = selectedItem
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
end

local function shopGUI()
    script.on_event(defines.events.on_gui_opened, function(event)
        if event.entity == nil then
            return
        end
        if event.entity.name == 'shop-buy' then
            local player = game.players[event.player_index]
            if not player or not player.valid then
                return
            end
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

function initModuleEconomy(player)
    global.economy = {
        balances = {},
        prices = {}
    }
    -- для работы с интерфейсами

    initPrices(player)
    -- global.economy.balances[player.force.index] = {coins = 0}
    global.economy.balances[player.name] = {
        coins = 0
    }

    salary(player)
    shopGUI()
end
