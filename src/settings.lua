--- Настройки отображаемые в `Настройки модов`
--- https://wiki.factorio.com/Tutorial:Mod_settings#Creation

--- [Economy] "До старта"
data:extend({{
    type = 'bool-setting',
    name = 'multiplayer-teams:economy:enable',
    setting_type = 'startup',
    default_value = true,
    order = 'b-economy-a'
}})

--- [Logger] "Карта"
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

--- [Teams] "До старта"
data:extend({{
    type = 'bool-setting',
    name = 'multiplayer-teams:teams:enable',
    setting_type = 'startup',
    default_value = true,
    order = 'b-teams-a'
}, {
    type = 'string-setting',
    name = 'multiplayer-teams:teams:defaultForceName',
    setting_type = 'startup',
    default_value = 'player',
    allow_blank = false,
    auto_trim = false,
    hidden = true
}})

--- [Teams] "Карта"
data:extend({{
    type = 'string-setting',
    name = 'multiplayer-teams:teams:prefix',
    setting_type = 'runtime-global',
    default_value = 'Команда ',
    allow_blank = true,
    auto_trim = true,
    order = 'b-teams-b'
}, {
    type = 'int-setting',
    name = 'multiplayer-teams:teams:invite-timeout',
    setting_type = 'runtime-global',
    default_value = 1,
    minimum_value = 1,
    maximum_value = 60,
    order = 'b-teams-c'
}})

--- [Relations] "До старта"
data:extend({{
    type = 'bool-setting',
    name = 'multiplayer-teams:relations:enable',
    setting_type = 'runtime-global',
    default_value = true,
    order = 'c-relations-a'
}, {
    type = 'int-setting',
    name = 'multiplayer-teams:relations:offer-timeout',
    setting_type = 'runtime-global',
    default_value = 1,
    minimum_value = 1,
    maximum_value = 60,
    order = 'с-relations-b'
}})

--- [GUI] "Карта"
data:extend({{
    type = 'bool-setting',
    name = 'multiplayer-teams:gui:enable',
    setting_type = 'runtime-global',
    default_value = true,
    order = 'a-gui-a',
    forced_value = false, -- Если hidden = true, то будет это значение
    hidden = false
}})
