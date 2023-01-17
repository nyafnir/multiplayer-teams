local prefix = 2

data:extend({
    {
        type = 'bool-setting',
        name = 'mt:teams:enabled',
        setting_type = 'startup',
        localised_name = { "mt:settings:teams.enabled-name" },
        localised_description = { "mt:settings:teams.enabled-desc" },
        default_value = true,
        order = prefix .. '-teams-' .. 1
    }, {
        type = 'int-setting',
        name = 'mt:teams:invite-timeout',
        setting_type = 'startup',
        localised_name = { "mt:settings:teams.timeout-invite-name" },
        localised_description = { "mt:settings:teams.timeout-invite-desc" },
        default_value = 1,
        minimum_value = 1,
        maximum_value = 60,
        order = prefix .. '-teams-' .. 3
    },
})
