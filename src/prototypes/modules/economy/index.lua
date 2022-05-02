--вода беспланая
--magic number наценка за производство
local EXTRA_CHARGE = 1
--ore magic изначальная цена руды
local ORE_PRICE = 1
--fluid magic коээфицент для жидкостей
local FLUID_COEFFICIENT = 0.3
--врмея ЗП в минутах
local TIME_SALARY = 2
-- 1 секунда = 60 тиков, 1 минута = 60 тиков * 60 секунд
local ticksToSalary = 60 * 60

---при первом запуске проинициализировать цену продукции
local function initPrices (player)   
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
            price = price + checkReceipt(ingredient.name) * ingredient.amount
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
    for item, _ in pairs(game.fluid_prototypes ) do
        local icf, ocf = 0, 0
        icf = player.force.fluid_production_statistics.get_flow_count({name = item, input = true, precision_index = defines.flow_precision_index.one_minute, count = true})
        ocf = player.force.fluid_production_statistics.get_flow_count({name = item, input = false, precision_index = defines.flow_precision_index.one_minute, count = true})
        player.print(item..' добыто: '..icf..' потрачено: '..ocf)
     
        if icf > 0 then
            if not item == 'water' then
                sum = sum + icf * FLUID_COEFFICIENT
            end
        end

        if ocf > 0 then
            if not item == 'water' then
                sum = sum - ocf * FLUID_COEFFICIENT
            end
        end
    end
    for item, _ in pairs(game.item_prototypes) do
        local ic, oc = 0, 0
        ic = player.force.item_production_statistics.get_flow_count({name = item, input = true, precision_index = defines.flow_precision_index.one_minute, count = true})
        local fic = player.force.item_production_statistics.get_flow_count({name = item, input = true, precision_index = defines.flow_precision_index.one_minute, count = false})
        oc = player.force.item_production_statistics.get_flow_count({name = item, input = false, precision_index = defines.flow_precision_index.one_minute, count = true})
        if ic > 0 then
            player.print(item..' ic : '..ic..' * '..global.economy.prices[item])
            sum = sum + ic * global.economy.prices[item]
        end
        if oc > 0 then
            player.print(item..' oc : '..oc..' * '..global.economy.prices[item])
            sum = sum - oc * global.economy.prices[item]
        end
     end
     return sum
end

local function salary(player)
    local iteration, sum = 0, 0
    script.on_nth_tick(
        ticksToSalary, 
        function(event)
            iteration = iteration + 1
            game.print(event.tick)
            sum = sum + accamulateSalary(player)
            player.print('есть вхождение')
            if iteration == TIME_SALARY then
                if sum > 0 then
                    addCash(player.name, sum)
                    player.print('Начисление зп в размере '..sum..' всего на счету: '..global.economy.balances[player.name].coins)
                else
                    player.print('Корпарация вами не довольна. В этот раз вы потратили ресурсов больше чем добыли, поэтому деньги не будут начислены.\nВсего на счету: '..global.economy.balances[player.name].coins)
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
--checkValidBuild()

---кладем предметы в маркет и достаем ?авторазгрузка/погрузка манипуляторами?
-- pushItemsInMarket()
-- popItemsFromMarket()

function initModuleEconomy(player)
    global.economy = { balances = {}, prices = {}}
    initPrices(player)
    -- global.balances[player.force.index] = {coins = 0}
    global.economy.balances[player.name] = {coins = 0}
    salary(player)
end
