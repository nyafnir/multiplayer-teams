data:extend({{
    type = 'bool-setting',
    name = 'multiplayer-teams:relations:enable',
    setting_type = 'startup',
    default_value = true,
    order = 'relations-a'
}, {
    type = 'int-setting',
    name = 'multiplayer-teams:relations:offer-timeout',
    setting_type = 'startup',
    default_value = 1,
    minimum_value = 1,
    maximum_value = 60,
    order = 'relations-b'
}})
