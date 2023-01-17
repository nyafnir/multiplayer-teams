local prefix = 6

data:extend({
    {
        type = 'bool-setting',
        name = 'mt:quests:enabled',
        setting_type = 'startup',
        localised_name = { "mt:settings:quests.enabled-name" },
        localised_description = { "mt:settings:quests.enabled-desc" },
        default_value = true,
        order = prefix .. '-quests-' .. 1
    }
})
