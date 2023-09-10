local prefix = 1

data:extend({
    {
        type = 'bool-setting',
        name = 'mt:gui:enabled',
        setting_type = 'runtime-global',
        localised_name = { "mt:settings:gui.enabled-name" },
        localised_description = { "mt:settings:gui.enabled-desc" },
        default_value = true,
        order = prefix .. '-gui-' .. 1
    }
})
