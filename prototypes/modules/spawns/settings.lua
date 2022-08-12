local prefix = 3

-- Пояснения к настройкам в ./config.lua

data:extend({
    {
        type = 'bool-setting',
        name = 'multiplayer-teams:spawns:enable',
        setting_type = 'startup',
        default_value = true,
        order = prefix .. '-spawns-1'
    }
})

data:extend({
    {
        type = 'int-setting',
        name = 'multiplayer-teams:spawns:archimedean-spiral:step',
        setting_type = 'startup',
        default_value = 2,
        minimum_value = 1,
        order = prefix .. '-spawns-2-1',
        hidden = true
    }, {
        type = 'int-setting',
        name = 'multiplayer-teams:spawns:archimedean-spiral:distance',
        setting_type = 'startup',
        default_value = 50,
        minimum_value = 1,
        order = prefix .. '-spawns-2-2',
        hidden = true
    }
})

data:extend({
    {
        type = 'int-setting',
        name = 'multiplayer-teams:spawns:options:radius:near',
        setting_type = 'startup',
        default_value = 150,
        minimum_value = 50,
        order = prefix .. '-spawns-3-1',
        hidden = false
    }, {
        type = 'int-setting',
        name = 'multiplayer-teams:spawns:options:radius:far',
        setting_type = 'startup',
        default_value = 300,
        minimum_value = 50,
        order = prefix .. '-spawns-3-2',
        hidden = false
    }
})

data:extend({
    {
        type = 'int-setting',
        name = 'multiplayer-teams:spawns:options:respawn:timeout',
        setting_type = 'startup',
        default_value = 10, -- минуты
        minimum_value = 5,
        maximum_value = 60,
        order = prefix .. '-spawns-4'
    }
})

data:extend({
    {
        type = 'string-setting',
        name = 'multiplayer-teams:spawns:options:resources',
        setting_type = 'startup',
        order = prefix .. '-spawns-99',
        hidden = false,
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
    }
})
