local sum = {}

---@param force LuaForce
local function accamulateSalary(force)
    local sum = 0

    for item, _ in pairs(game.fluid_prototypes) do
        if item == 'water' then goto continue end
        local icf, ocf = 0, 0
        icf = force.fluid_production_statistics.get_flow_count({
            name = item,
            input = true,
            precision_index = defines.flow_precision_index.one_minute,
            count = true
        })
        ocf = force.fluid_production_statistics.get_flow_count({
            name = item,
            input = false,
            precision_index = defines.flow_precision_index.one_minute,
            count = true
        })

        if icf > 0 then sum = sum + math.floor(icf * economyModule.config.fluidCoefficient) end

        if ocf > 0 then sum = sum - math.floor(ocf * economyModule.config.fluidCoefficient) end
        ::continue::
    end

    for item, _ in pairs(game.item_prototypes) do
        local ic, oc = 0, 0
        ic = force.item_production_statistics.get_flow_count({
            name = item,
            input = true,
            precision_index = defines.flow_precision_index.one_minute,
            count = true
        })
        local fic = force.item_production_statistics.get_flow_count({
            name = item,
            input = true,
            precision_index = defines.flow_precision_index.one_minute,
            count = false
        })
        oc = force.item_production_statistics.get_flow_count({
            name = item,
            input = false,
            precision_index = defines.flow_precision_index.one_minute,
            count = true
        })
        if ic > 0 then sum = sum + ic * economyModule.service.getEconomy().prices[item] end
        if oc > 0 then sum = sum - oc * economyModule.service.getEconomy().prices[item] end
    end

    return sum
end

script.on_nth_tick(Utils.time.convertMinutesToTicks(1), function()
    if Utils.table.getSize(economyModule.service.getEconomy().balances) == 0 then
        return
    end

    global.iteration = global.iteration or 0
    global.iteration = global.iteration + 1

    -- teams.store.forces

    for teamName, _ in pairs(economyModule.service.getEconomy().balances) do
        if teamName == teamModule.service.defaultForceName then
            goto continue
        end

        local force = game.forces[teamName]
        if sum[teamName] == nil then
            sum[teamName] = 0
        end

        sum[teamName] = sum[teamName] + accamulateSalary(force)
        if global.iteration == economyModule.config.timeSalary then
            if sum[teamName] > 0 then
                economyModule.service.addCash(teamName, sum[teamName])
                force.print('Начисление зп в размере ' ..
                    sum[teamName] .. ' всего на счету: ' ..
                    economyModule.service.getEconomy().balances[teamName].coins)
            else
                force.print(
                    'Корпарация вами не довольна. В этот раз вы потратили ресурсов больше чем добыли, поэтому деньги не будут начислены.\nВсего на счету: '
                    ..
                    economyModule.service.getEconomy().balances[teamName].coins)
            end

            global.iteration, sum = 0, {}
        end

        ::continue::
    end
end)
