local this = {}

local hasGlobal = false

---@param itemName string
local function checkReceipt(itemName)
    if global.economy.prices[itemName] then
        return global.economy.prices[itemName]
    end

    local force = game.forces[teamModule.service.defaultForceName]
    local receipt = force.recipes[itemName]
    if receipt == nil then
        global.economy.prices[itemName] = economyModule.config.priceOre
        return economyModule.config.priceOre
    end

    local price = 0
    for _, ingredient in pairs(receipt.ingredients) do
        if ingredient.type == 'fluid' then
            price = price + ingredient.amount * economyModule.config.fluidCoefficient
        else
            price = price + checkReceipt(ingredient.name) *
                ingredient.amount
        end
    end

    local countProducts = 0
    for _, product in pairs(receipt.products) do
        countProducts = countProducts + product.amount
    end

    local result = math.ceil(price / countProducts) + economyModule.config.priceProduction
    global.economy.prices[itemName] = result
    return result
end

function this.getEconomy()
    if hasGlobal then
        return global.economy
    end

    if global.economy == nil then
        global.economy = {
            prices = {},
            balances = {}
        }
    end

    ---Перепроверяем все существующие рецепты - добавляем в свою базу знаний
    for itemName, _ in pairs(game.item_prototypes) do checkReceipt(itemName) end

    ---Проходим по всем командам и инициализируем баланс
    for teamName, _ in pairs(game.forces) do
        ---Такая команда есть в нашем модуле? Тогда пропускаем
        if global.economy.balances[teamName] ~= nil then
            goto continue
        end

        global.economy.balances[teamName] = {
            coins = 0
        }

        ::continue::
    end

    hasGlobal = true
    return this.getEconomy()
end

---Добавить монет на счет команды.
---@param teamName number
---@param amount number
function this.addCash(teamName, amount)
    this.getEconomy().balances[teamName].coins =
    this.getEconomy().balances[teamName].coins + amount
end

return this
