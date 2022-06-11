data:extend({{
    type = 'bool-setting',
    name = 'multiplayer-teams:spawns:enable',
    setting_type = 'startup',
    default_value = true,
    order = 'd-spawns-a'
}, {
    type = 'int-setting',
    name = 'multiplayer-teams:spawns:respawn-timeout',
    setting_type = 'startup',
    default_value = 10, -- минуты
    minimum_value = 5,
    maximum_value = 60,
    order = 'd-spawns-r'
}})

-- Скрытые параметры:
data:extend({{
    type = 'int-setting',
    name = 'multiplayer-teams:spawns:archimedean-spiral:distance',
    setting_type = 'startup',
    default_value = 50,
    minimum_value = 0,
    order = 'd-spawns-z',
    hidden = true
}, {
    type = 'int-setting',
    name = 'multiplayer-teams:spawns:archimedean-spiral:step',
    setting_type = 'startup',
    default_value = 2,
    minimum_value = 0,
    order = 'd-spawns-z',
    hidden = true
}, {
    type = 'int-setting',
    name = 'multiplayer-teams:spawns:base:internal-radius',
    setting_type = 'startup',
    default_value = 96, --- это 3 чанка
    minimum_value = 0,
    order = 'd-spawns-z',
    hidden = true
}, {
    type = 'int-setting',
    name = 'multiplayer-teams:spawns:base:external-radius',
    setting_type = 'startup',
    default_value = 600, --- это 23 чанка
    minimum_value = 0,
    order = 'd-spawns-z',
    hidden = true
}})
