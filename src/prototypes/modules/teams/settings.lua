data:extend({{
    type = 'bool-setting',
    name = 'multiplayer-teams:teams:enable',
    setting_type = 'startup',
    default_value = true,
    order = 'b-teams-a'
}, {
    type = 'int-setting',
    name = 'multiplayer-teams:teams:invite-timeout',
    setting_type = 'startup',
    default_value = 1,
    minimum_value = 1,
    maximum_value = 60,
    order = 'b-teams-t'
}})

data:extend({{
    type = 'string-setting',
    name = 'multiplayer-teams:teams:defaultForceName',
    setting_type = 'startup',
    --- здесь используются команды создаваемые по умолчанию в игре
    default_value = 'player', -- player | enemy | neutral
    order = 'b-teams-z',
    allow_blank = false,
    auto_trim = true,
    hidden = true
}})
