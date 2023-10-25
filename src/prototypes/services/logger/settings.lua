local context = 'logger'
local prefixOrder = 99
local prefixName = ConfigService.prefixes.default

data:extend({
    {
        order = prefixOrder .. '-' .. context .. '-' .. 1,
        name = prefixName .. ':' .. context .. ':' .. 'prefix:title',
        type = 'string-setting',
        setting_type = 'runtime-global',
        default_value = 'MultiplayerTeams',
        allow_blank = true,
        auto_trim = true,
        localised_name = { 'mt.logger.settings.prefix.title.name' },
    },
    {
        order = prefixOrder .. '-' .. context .. '-' .. 2,
        name = prefixName .. ':' .. context .. ':' .. 'prefix:color',
        type = 'color-setting',
        setting_type = 'runtime-global',
        -- orange
        default_value = { 255, 95, 21 },
        localised_name = { 'mt.logger.settings.prefix.color.name' },
    }
})

data:extend({
    {
        order = prefixOrder .. '-' .. context .. '-d' .. 1,
        name = prefixName .. ':' .. context .. ':' .. 'debug:enabled',
        type = 'bool-setting',
        setting_type = 'runtime-per-user',
        default_value = true,
        localised_name = { 'mt.logger.settings.debug.enabled.name' },
    },
    {
        order = prefixOrder .. '-' .. context .. '-d' .. 2,
        name = prefixName .. ':' .. context .. ':' .. 'debug:prefix:title',
        type = 'string-setting',
        setting_type = 'runtime-per-user',
        default_value = 'MultiplayerTeams',
        allow_blank = true,
        auto_trim = true,
        localised_name = { 'mt.logger.settings.debug.prefix.title.name' },
    },
    {
        order = prefixOrder .. '-' .. context .. '-d' .. 3,
        name = prefixName .. ':' .. context .. ':' .. 'debug:prefix:color',
        type = 'color-setting',
        setting_type = 'runtime-per-user',
        -- aqua light
        default_value = { 140, 255, 219 },
        localised_name = { 'mt.logger.settings.debug.prefix.color.name' },
    }
})
