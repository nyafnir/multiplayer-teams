data:extend({{
    type = 'bool-setting',
    name = 'multiplayer-teams:logger:enable',
    setting_type = 'runtime-global',
    default_value = true,
    order = 'z-a',
    forced_value = false, -- Если hidden = true, то будет это значение
    hidden = false
}, {
    type = 'string-setting',
    name = 'multiplayer-teams:logger:prefix',
    setting_type = 'runtime-global',
    default_value = '[MT-DEBUG] ',
    order = 'z-b',
    allow_blank = true,
    auto_trim = false,
    hidden = false
}})
