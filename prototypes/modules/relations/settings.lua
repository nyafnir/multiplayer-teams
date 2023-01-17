local prefix = 4

data:extend({
    {
        type = 'bool-setting',
        name = 'multiplayer-teams:relations:enabled',
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
    },
    -- {
    --     type = 'bool-setting',
    --     name = 'mt:teams:friendly-fire:enabled',
    --     setting_type = 'startup',
    --     localised_name = { "mt:settings:teams.enabled-friendly-fire-name" },
    --     localised_description = { "mt:settings:teams.enabled-friendly-fire-desc" },
    --     default_value = true,
    --     order = prefix .. '-teams-' .. 2
    -- },
})
