---при первом запуске проинициализировать цену продукции

local DELAY = 20

local function delay()
    global.tickswait = 0
    while global.tickswait >= DELAY do
    end   
end

function initPrices (player)
    --for _, p in pairs(game.item_prototypes) do
    --    player.print(p.name)
    --    if player.force.recipes[p.name] then
    --        
    --    end
    --end

    local function checkReceipt(name)
        player.print('in')
        player.print(name)
        -- if not player.force.recipes[name] then
        --save Table [name; price] --жидкость 0,01 прайс -- вода 0
        --    player.print('with 1 out for: '..name)
        --    return 1
        --end
        if not player.force.recipes[name] then
            return
        end
        for _, p in pairs(player.force.recipes[name].ingredients) do
            player.print(p.name..' '..p.amount)
          
            checkReceipt(game.item_prototypes[p.name])
        end
        player.print('out for: '..name)
    end
    for _, p in pairs(player.force.recipes['lab'].ingredients) do
        player.print('start')
        player.print(p.name..' '..p.amount)
        delay()
        checkReceipt(p.name)
        player.print('end')
        --save Table [name; price]
    end


end

function onTick(event)
    global.tickswait += 1
    if global.tickswait == 1000 then
        global.tickswait = 0
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