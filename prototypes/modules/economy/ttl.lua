-- время между ЗП в минутах
local TIME_SALARY = 1
-- 1 секунда = 60 тиков, 1 минута = 60 тиков * 60 секунд
local ticksToSalary = 60 * 10
local sum = {}

-- fluid magic коээфицент для жидкостей
local FLUID_COEFFICIENT = 0.05

function addCash(teamId, cash)
    global.economy.balances[teamId].coins =
        global.economy.balances[teamId].coins + cash
end

local function accamulateSalary(player)
    local sum = 0
    for item, _ in pairs(game.fluid_prototypes) do
        if item == 'water' then goto continue end
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

        if icf > 0 then sum = sum + math.floor(icf * FLUID_COEFFICIENT) end

        if ocf > 0 then sum = sum - math.floor(ocf * FLUID_COEFFICIENT) end
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
        if ic > 0 then sum = sum + ic * global.economy.prices[item] end
        if oc > 0 then sum = sum - oc * global.economy.prices[item] end
    end
    return sum
end

script.on_nth_tick(ticksToSalary, function()
    if getSize(global.economy.balances) == 0 then return end
    global.iteration = global.iteration or 0
    global.iteration = global.iteration + 1
    -- teams.store.forces
    logger.debug(forces)
    for id, _ in pairs(global.economy.balances) do
        if id == 1 then goto continue end
        local player = getPlayerById(id)
        if sum[id] == nil then sum[id] = 0 end
        sum[id] = sum[id] + accamulateSalary(player)
        if global.iteration == TIME_SALARY then
            if sum[id] > 0 then
                addCash(id, sum[id])
                player.print('Начисление зп в размере ' ..
                                 sum[id] .. ' всего на счету: ' ..
                                 global.economy.balances[id].coins)
            else
                player.print(
                    'Корпарация вами не довольна. В этот раз вы потратили ресурсов больше чем добыли, поэтому деньги не будут начислены.\nВсего на счету: ' ..
                        global.economy.balances[id].coins)
            end
            global.iteration, sum = 0, {}
        end
        ::continue::
    end
end)
