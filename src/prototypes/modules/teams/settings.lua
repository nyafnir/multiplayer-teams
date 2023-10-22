local context = 'teams'
local prefixOrder = 2
local prefixName = ConfigService.prefixes.default

data:extend({
    {
        order = prefixOrder .. '-' .. context .. '-' .. 1,
        name = prefixName .. ':' .. context .. ':' .. 'invite-timeout',
        type = 'int-setting',
        setting_type = 'runtime-global',
        default_value = 1,
        minimum_value = 1,
        maximum_value = 1440, --- сутки
        localised_name = { prefixName .. ':' .. context .. '.' .. 'invite-timeout-name' },
        localised_description = { prefixName .. ':' .. context .. '.' .. 'invite-timeout-description' },
    },
})
