local prefix = 4

data:extend({
    {
        type = 'bool-setting',
        name = 'multiplayer-teams:relations:enable',
        setting_type = 'startup',
        default_value = true,
        order = prefix .. '-relations-1'
    }, {
        type = 'int-setting',
        name = 'multiplayer-teams:relations:offer-timeout',
        setting_type = 'startup',
        default_value = 1,
        minimum_value = 1,
        maximum_value = 60,
        order = prefix .. '-relations-2'
    }
})
