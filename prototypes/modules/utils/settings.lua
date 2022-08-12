local prefix = 99

data:extend({
    {
        type = 'bool-setting',
        name = 'multiplayer-teams:logger:enable',
        setting_type = 'startup',
        default_value = true,
        order = prefix .. '-logger-1',
        forced_value = false, -- Если hidden = true, то будет это значение
        hidden = false
    }
})

data:extend({
    {
        type = 'string-setting',
        name = 'multiplayer-teams:logger:prefix',
        setting_type = 'startup',
        default_value = '[MultiplayerTeams]',
        order = prefix .. '-logger-2',
        allow_blank = true,
        auto_trim = true,
        hidden = false
    }
})
