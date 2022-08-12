local prefix = 2

data:extend({
    {
        type = 'bool-setting',
        name = 'multiplayer-teams:teams:enable',
        setting_type = 'startup',
        default_value = true,
        order = prefix .. '-teams-1'
    }, {
        type = 'int-setting',
        name = 'multiplayer-teams:teams:invite-timeout',
        setting_type = 'startup',
        default_value = 1,
        minimum_value = 1,
        maximum_value = 60,
        order = prefix .. '-teams-3'
    }
})
