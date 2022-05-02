--вода беспланая
--magic number наценка за производство
local EXTRA_CHARGE = 1
--ore magic изначальная цена руды
local ORE_PRICE = 1
--fluid magic коээфицент для жидкостей
local FLUID_COEFFICIENT = 0.3
--врмея ЗП в минутах
local TIME_SALARY = 24
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
    for item, _ in pairs(game.fluid_prototypes ) do
        if item == 'water' then goto continue end
        local icf, ocf = 0, 0
        icf = player.force.fluid_production_statistics.get_flow_count({name = item, input = true, precision_index = defines.flow_precision_index.one_minute, count = true})
        ocf = player.force.fluid_production_statistics.get_flow_count({name = item, input = false, precision_index = defines.flow_precision_index.one_minute, count = true})
     
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
        ic = player.force.item_production_statistics.get_flow_count({name = item, input = true, precision_index = defines.flow_precision_index.one_minute, count = true})
        local fic = player.force.item_production_statistics.get_flow_count({name = item, input = true, precision_index = defines.flow_precision_index.one_minute, count = false})
        oc = player.force.item_production_statistics.get_flow_count({name = item, input = false, precision_index = defines.flow_precision_index.one_minute, count = true})
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
    script.on_nth_tick(
        ticksToSalary, 
        function(event)
            iteration = iteration + 1
            game.print(event.tick)
            sum = sum + accamulateSalary(player)
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
    -- global.economy.balances[player.force.index] = {coins = 0}
    global.economy.balances[player.name] = {coins = 0}
    salary(player)
end
