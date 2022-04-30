--вода беспланая
--magic number наценка за производство
local EXTRA_CHARGE = 1
--ore magic изначальная цена руды
local ORE_PRICE = 1
--fluid magic коээфицент для жидкостей
local FLUID_COEFFICIENT = 0.02

---при первом запуске проинициализировать цену продукции
function initPrices (player)
    global.prices = {}
   
    local function checkReceipt(name, typeProduct)
        if global.prices[name] then
            return global.prices[name]
        end
        local receipt = player.force.recipes[name]
        if receipt == nil or typeProduct == 'fluid' then
            local result = ORE_PRICE
            if typeProduct == 'item' then
                global.prices[name] = result
                 return result
            end
            if name == 'water' then 
                global.prices[name] = 0
                return 0
            end
            global.prices[name] = result * FLUID_COEFFICIENT
            return result * FLUID_COEFFICIENT
        end
            
        local price = 0

        for _, ingredient in pairs(receipt.ingredients) do
            price = price + checkReceipt(ingredient.name, ingredient.type) * ingredient.amount
        end      

        local countProducts = 0
            
        for _, product in pairs(receipt.products) do
            countProducts = countProducts + product.amount
        end
        local result = math.ceil(price / countProducts) + EXTRA_CHARGE
        global.prices[name] = result
        return result
    end

    price = 0
     
    for _, p in pairs(game.item_prototypes) do
        local result = checkReceipt(p.name, p.type)
        logger(p.name..': '..result)
     end
   
end


--initModuleEconomy(player)

---утром начисляется ЗП за ((P1 - Q1) * S1 + (P2 - Q2) * S2 ...) Pn - произведено, Qn - потреблено, Sn - цена за продукцию. Так получим капитал активных ресурсов (если Pn - Qn < 0 то считать за 0)
-- salary()

---обмен
-- trade(teamId1, teamId2, products)

---нельзя положить сломанный предмет на продажу или для задания
-- checkBrokenItem()

---проверка на валидность здания (существует ли еще)
--checkValidBuild()

---кладем предметы в маркет и достаем ?авторазгрузка/погрузка манипуляторами?
-- pushItemsInMarket()
-- popItemsFromMarket()