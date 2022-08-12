local prefix = 1

data:extend({
    {
        type = 'bool-setting',
        name = 'multiplayer-teams:gui:enable',
        setting_type = 'runtime-global',
        default_value = true,
        order = prefix .. '-gui-1',
        forced_value = false, -- Если hidden = true, то будет это значение
        hidden = false
    }
})
