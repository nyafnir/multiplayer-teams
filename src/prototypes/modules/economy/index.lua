--вода беспланая
--magic number наценка за производство
local EXTRA_CHARGE = 1
--ore magic изначальная цена руды
local ORE_PRICE = 1
--fluid magic коээфицент для жидкостей
local FLUID_COEFFICIENT = 0.02
--врмея ЗП в минутах
local TIME_SALARY = 2
-- 1 секунда = 60 тиков, 1 минута = 60 тиков * 60 секунд
local ticksToSalary = 60 * 60

---при первом запуске проинициализировать цену продукции
local function initPrices (player)
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
     
    for _, item in pairs(game.item_prototypes) do
        local result = checkReceipt(item.name, item.type)
        logger(item.name..': '..result)
     end
   
end

local function setCash(playerName, cash)
    global[playerName].coins = cash
end

local function addCash(playerName, cash)
    global[playerName].coins = global[playerName].coins + cash
end

local function popCash(playerName, cash)
    global[playerName].coins = global[playerName].coins - cash
end

local function accamulateSalary(player)
    local sum = 0
    for _, item in pairs(game.item_prototypes) do
        local ic, oc, icf, ocf = 0, 0, 0, 0
        
        if item.type == 'item' then
            ic = player.force.item_production_statistics.get_flow_count({name = item.name, input = true, precision_index = defines.flow_precision_index.one_minute, count = true})
            local fic = player.force.item_production_statistics.get_flow_count({name = item.name, input = true, precision_index = defines.flow_precision_index.one_minute, count = false})
            if ic > 0 or fic > 0 then
                player.print(item.name..': ic: '..ic..'. fic: '..fic)
            end
            oc = player.force.item_production_statistics.get_flow_count({name = item.name, input = false, precision_index = defines.flow_precision_index.one_minute, count = true})
        end
        if item.type == 'fluid' then
            icf = player.force.fluid_production_statistics.get_flow_count({name = item.name, input = true, precision_index = defines.flow_precision_index.one_minute, count = true})
            ocf = player.force.fluid_production_statistics.get_flow_count({name = item.name, input = false, precision_index = defines.flow_precision_index.one_minute, count = true})
        end

        if icf > 0 then
            if not item.name == 'water' then
                sum = sum + icf / 100
            end
        end

        if ocf > 0 then
            if not item.name == 'water' then
                sum = sum - ocf / 100
            end
        end

        if ic > 0 then
            player.print(item.name..' ic : '..ic..' * '..global.prices[item.name])
            sum = sum + ic * global.prices[item.name]
        end
        if oc > 0 then
            player.print(item.name..' oc : '..oc..' * '..global.prices[item.name])
            sum = sum - oc * global.prices[item.name]

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
                player.print('зп')
                if sum > 0 then
                    addCash(player.name, sum)
                    player.print('Начисление зп в размере '..sum..' всего на счету: '..global[player.name].coins)
                else
                    player.print('Корпарация вами не довольна. В этот раз вы потратили ресурсов больше чем добыли, поэтому деньги не будут начислены.\nВсего на счету: '..global[player.name].coins)
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
    initPrices(player)
    global[player.name] = {coins = 0}
    salary(player)
end
