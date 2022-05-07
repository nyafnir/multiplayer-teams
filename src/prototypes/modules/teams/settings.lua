data:extend({{
    type = 'bool-setting',
    name = 'multiplayer-teams:teams:enable',
    setting_type = 'startup',
    default_value = true,
    order = 'b-teams-a'
}, {
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

data:extend({{
    type = 'string-setting',
    name = 'multiplayer-teams:teams:defaultForceName',
    setting_type = 'startup',
    --- здесь используются команды создаваемые по умолчанию в игре
    default_value = 'player', -- player | enemy | neutral 
    allow_blank = false,
    auto_trim = false,
    hidden = true
}})
