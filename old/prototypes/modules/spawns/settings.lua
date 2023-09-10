local prefix = 3

data:extend({
    {
        order = prefix .. '-spawns-'.. 0,
        name = 'mt:spawns:enabled',
        default_value = true,
        type = 'bool-setting',
        setting_type = 'startup',
        localised_name = { "mt:settings:spawns.enabled-name" },
        localised_description = { "mt:settings:spawns.enabled-desc" },
    }
})

data:extend({
    {
        order = prefix .. '-spawns-'.. 10,
        name = 'mt:spawns:options:radius:near',
        default_value = 150,
        minimum_value = 50,
        type = 'int-setting',
        setting_type = 'startup',
        localised_name = { "mt:settings:relations.timeout-offer-name" },
        localised_description = { "mt:settings:relations.timeout-offer-desc" },
        hidden = false
    }, {
        order = prefix .. '-spawns-'.. 11,
        name = 'mt:spawns:options:radius:far',
        default_value = 300,
        minimum_value = 50,
        type = 'int-setting',
        setting_type = 'startup',
        hidden = false
    }, {
        order = prefix .. '-spawns-'.. 12,
        name = 'mt:spawns:options:radius:far',
        default_value = 300,
        minimum_value = 50,
        type = 'int-setting',
        setting_type = 'startup',
        hidden = false
    }
})

data:extend({
    {
        order = prefix .. '-spawns-'.. 20,
        name = 'mt:spawns:options:respawn:timeout',
        default_value = 10, -- минуты
        minimum_value = 5,
        maximum_value = 60,
        type = 'int-setting',
        setting_type = 'startup',
    }
})

data:extend({
    {
        order = prefix .. '-spawns-'.. 30,
        name = 'mt:spawns:options:resources',
        default_value = [[{
            --- железо
            iron_ore = {
                name = 'iron-ore',
                type = 'fill',
                radius = 10,
                amount = 3000,
                location = 'above'
            },
            --- медь
            copper_ore = {
                name = 'copper-ore',
                type = 'fill',
                radius = 10,
                amount = 3000,
                location = 'above'
            },
            --- уголь
            coal = {
                name = 'coal',
                type = 'fill',
                radius = 10,
                amount = 3000,
                location = 'above'
            },
            --- камень
            stone = {
                name = 'stone',
                type = 'fill',
                radius = 10,
                amount = 3000,
                location = 'near'
            },
            --- древесина
            trees = {
                name = 'trees',
                type = 'fill',
                radius = 10,
                amount = 3000,
                location = 'near'
            },
            --- уран
            uranium_ore = {
                name = 'uranium_ore',
                type = 'fill',
                radius = 10,
                amount = 3000,
                location = 'far'
            },
            --- нефть
            crude_oil = {
                name = 'crude_oil',
                type = 'dotted',
                count = 8, -- всего точек
                radius = 10, -- в пределах этого радиуса
                amount = 3000, -- количество в каждой точке
                location = 'far'
            }
        }]]
    },
    type = 'string-setting',
    setting_type = 'startup',
    hidden = false,
})
