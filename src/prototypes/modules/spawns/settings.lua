data:extend({{
    type = 'bool-setting',
    name = 'multiplayer-teams:spawns:enable',
    setting_type = 'startup',
    default_value = true,
    order = 'd-spawns-a'
}, {
    type = 'int-setting',
    name = 'multiplayer-teams:spawns:near-distance',
    setting_type = 'startup',
    default_value = 25,
    minimum_value = 10,
    maximum_value = 100,
    order = 'd-spawns-n'
}, {
    type = 'int-setting',
    name = 'multiplayer-teams:spawns:far-distance',
    setting_type = 'startup',
    default_value = 75,
    minimum_value = 50,
    maximum_value = 500,
    order = 'd-spawns-f'
}, {
    type = 'int-setting',
    name = 'multiplayer-teams:spawns:respawn-timeout',
    setting_type = 'startup',
    default_value = 10, -- минуты
    minimum_value = 5,
    maximum_value = 60,
    order = 'd-spawns-r'
}})
