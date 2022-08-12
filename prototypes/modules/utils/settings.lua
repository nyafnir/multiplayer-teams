data:extend({{
    type = 'bool-setting',
    name = 'multiplayer-teams:logger:enable',
    setting_type = 'startup',
    default_value = true,
    order = 'z-logger-a',
    forced_value = false, -- Если hidden = true, то будет это значение
    hidden = false
}})

data:extend({{
    type = 'string-setting',
    name = 'multiplayer-teams:logger:prefix',
    setting_type = 'startup',
    default_value = '[MT-DEBUG]',
    order = 'z-logger-z',
    allow_blank = true,
    auto_trim = true,
    hidden = true
}})
