local prefix = 99

data:extend({
    {
        type = 'bool-setting',
        name = 'mt:logger:enabled',
        setting_type = 'startup',
        localised_name = { "mt:settings:logger.enabled-name" },
        localised_description = { "mt:settings:logger.enabled-desc" },
        default_value = true,
        order = prefix .. '-logger-' .. 1,
    }
})

data:extend({
    {
        type = 'string-setting',
        name = 'mt:logger:prefix',
        setting_type = 'startup',
        localised_name = { "mt:settings:logger.prefix-name" },
        localised_description = { "mt:settings:logger.prefix-desc" },
        default_value = '[MultiplayerTeams]',
        order = prefix .. '-logger-' .. 2,
        allow_blank = false,
        auto_trim = true,
    }
})
