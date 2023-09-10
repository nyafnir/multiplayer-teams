local prefix = 2

data:extend({ {
    type = 'bool-setting',
    name = 'mt:economy:enabled',
    setting_type = 'startup',
    localised_name = { "mt:settings:economy.enabled-name" },
    localised_description = { "mt:settings:economy.enabled-desc" },
    default_value = true,
    order = prefix .. '-economy-' .. 1
}, {
    type = 'int-setting',
    name = 'mt:economy:salary-interval',
    setting_type = 'startup',
    localised_name = { "mt:settings:economy.salary-interval-name" },
    localised_description = { "mt:settings:economy.salary-interval-desc" },
    default_value = 1,
    minimum_value = 1,
    maximum_value = 60,
    order = prefix .. '-economy-' .. 2
}, {
    type = 'int-setting',
    name = 'mt:economy:fluid-coefficient',
    setting_type = 'startup',
    localised_name = { "mt:settings:economy.fluid-coefficient-name" },
    localised_description = { "mt:settings:economy.fluid-coefficient-desc" },
    default_value = 0.05,
    minimum_value = 0.001,
    maximum_value = 100,
    order = prefix .. '-economy-' .. 3
}, {
    type = 'int-setting',
    name = 'mt:economy:price-ore',
    setting_type = 'startup',
    localised_name = { "mt:settings:economy.price-ore-name" },
    localised_description = { "mt:settings:economy.price-ore-desc" },
    default_value = 1,
    minimum_value = 0.1,
    maximum_value = 100,
    order = prefix .. '-economy-' .. 4
}, {
    type = 'int-setting',
    name = 'mt:economy:price-production',
    setting_type = 'startup',
    localised_name = { "mt:settings:economy.price-production-name" },
    localised_description = { "mt:settings:economy.price-production-desc" },
    default_value = 1,
    minimum_value = 0.1,
    maximum_value = 100,
    order = prefix .. '-economy-' .. 5
},
})
