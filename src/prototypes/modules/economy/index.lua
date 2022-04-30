---при первом запуске проинициализировать цену продукции

function initPrices (player)
    --for _, p in pairs(game.item_prototypes) do
    --    player.print(p.name)
    --    if player.force.recipes[p.name] then
    --        
    --    end
    --end

    local function checkReceipt(name)
        -- if not player.force.recipes[name] then
        --save Table [name; price] --жидкость 0,01 прайс -- вода 0
        --    player.print('with 1 out for: '..name)
        --    return 1
        --end
        if type(name) == 'string' then
            local receipt = player.force.recipes[name]
            
            if receipt == nil then
                return 1
            end
            
            local price = 0

            for _, ingredient in pairs(receipt.ingredients) do
                price = price + checkReceipt(game.item_prototypes[ingredient.name].name) * ingredient.amount
            end      

            local countProducts = 0
            
            for _, product in pairs(receipt.products) do
                countProducts = countProducts + product.amount
            end
            
            local result = math.ceil(price / countProducts + 1)
            return result

        else
            player.print("checkReceipt: "..name.name)
        end
    end
   
    local price = 0
   
    for _, p in pairs(player.force.recipes['lab'].ingredients) do
        price = price + checkReceipt(p.name) * p.amount
        --save Table [name; price]
    end
    
    price = price + 1
    player.print('end. price = '..price)
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