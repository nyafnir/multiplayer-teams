local prefix = 2

data:extend({ {
    type = 'bool-setting',
    name = 'mt:economy:enabled',
    setting_type = 'startup',
    localised_name = { "mt:settings:economy.enabled-name" },
    localised_description = { "mt:settings:economy.enabled-desc" },
    default_value = true,
    order = prefix .. '-economy-' .. 1
} })
