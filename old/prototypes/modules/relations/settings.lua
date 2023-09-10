local prefix = 4

data:extend({
    {
        type = 'bool-setting',
        name = 'mt:relations:enabled',
        setting_type = 'startup',
        localised_name = { "mt:settings:relations.enabled-name" },
        localised_description = { "mt:settings:relations.enabled-desc" },
        default_value = true,
        order = prefix .. '-relations-' .. 1
    }, {
        type = 'int-setting',
        name = 'mt:relations:offer-timeout',
        setting_type = 'startup',
        localised_name = { "mt:settings:relations.timeout-offer-name" },
        localised_description = { "mt:settings:relations.timeout-offer-desc" },
        default_value = 1,
        minimum_value = 1,
        maximum_value = 60,
        order = prefix .. '-relations-' .. 2
    },
    {
        type = 'bool-setting',
        name = 'mt:relations:friendly-fire:enabled',
        setting_type = 'startup',
        localised_name = { "mt:settings:relations.enabled-friendly-fire-name" },
        localised_description = { "mt:settings:relations.enabled-friendly-fire-desc" },
        default_value = true,
        order = prefix .. '-relations-' .. 3
    },
})
