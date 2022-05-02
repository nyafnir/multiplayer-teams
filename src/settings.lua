--- Настройки отображаемые в `Настройки модов`
--- https://wiki.factorio.com/Tutorial:Mod_settings#Creation

--- TODO: отсортировать
data:extend({{
    type = 'int-setting', -- тип: bool, int, double, string, каждый тип имеет свои дополнительные поля
    name = 'multiplayer-teams:spawn-near-distance', -- В `locale/` определяется название `[mod-setting-name]` и описание `[mod-setting-description]`
    setting_type = 'startup', -- вкладка в окне настроек: startup, runtime-global, runtime-per-user
    default_value = 25,
    minimum_value = 10,
    maximum_value = 100,
    order = 'c-a' -- по этому полю происходит сортировка в списке настроек, пример: c < d
}, {
    type = 'int-setting',
    name = 'multiplayer-teams:spawn-far-distance',
    setting_type = 'startup',
    default_value = 75,
    minimum_value = 50,
    maximum_value = 500,
    order = 'c-b'
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
    name = 'multiplayer-teams:relations-enable',
    setting_type = 'startup',
    default_value = true,
    order = 'a-b'
}, {
    type = 'bool-setting',
    name = 'multiplayer-teams:logger-enable', 
    setting_type = 'runtime-global',
    default_value = true,
    order = 'z-a',
    forced_value = false, -- Если hidden = true, то будет это значение
    hidden = false
}, {
    type = 'string-setting',
    name = 'multiplayer-teams:logger-prefix', 
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
    order = 'a-teams-a'
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
    order = 'a-teams-b'
}, {
    type = 'int-setting',
    name = 'multiplayer-teams:teams:invite-timeout',
    setting_type = 'runtime-global',
    default_value = 10,
    minimum_value = 1,
    maximum_value = 60,
    order = 'a-teams-c'
}})
