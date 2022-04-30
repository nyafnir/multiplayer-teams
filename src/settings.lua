-- Настройки отображаемые в `Настройки модов`
-- После добавления сюда настройки нужно в `locale/` определить названия `[mod-setting-name]` и описания `[mod-setting-description]`

data:extend({{
    type = 'int-setting',
    name = 'multiplayer-teams:spawn-near-distance',
    setting_type = 'startup', -- вкладка
    default_value = 25,
    minimum_value = 10,
    maximum_value = 100,
    order = 'c' -- сортировка по этому полю происходит, пример: c < d
}, {
    type = 'int-setting',
    name = 'multiplayer-teams:spawn-far-distance',
    setting_type = 'startup',
    default_value = 75,
    minimum_value = 50,
    maximum_value = 500,
    order = 'd'
}, {
    type = 'int-setting',
    name = 'multiplayer-teams:respawn-timeout',
    setting_type = 'startup',
    default_value = 10, -- минуты
    minimum_value = 5,
    maximum_value = 60,
    order = 'b'
}, {
    type = 'bool-setting',
    name = 'multiplayer-teams:economy-enable',
    setting_type = 'startup',
    default_value = true,
    order = 'a-c'
}, {
    type = 'bool-setting',
    name = 'multiplayer-teams:quests-enable',
    setting_type = 'startup',
    default_value = true,
    order = 'a-d'
}, {
    type = 'bool-setting',
    name = 'multiplayer-teams:teams-enable',
    setting_type = 'startup',
    default_value = true,
    order = 'a-a'
}, {
    type = 'bool-setting',
    name = 'multiplayer-teams:relations-enable',
    setting_type = 'startup',
    default_value = true,
    order = 'a-b'
}})
