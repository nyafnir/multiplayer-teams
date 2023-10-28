local context = 'relations'
local prefixOrder = 3
local prefixName = ConfigService.prefixes.default

data:extend({
    {
        order = prefixOrder .. '-' .. context .. '-' .. 1,
        name = prefixName .. ':' .. context .. ':' .. 'request:timeout',
        type = 'int-setting',
        setting_type = 'runtime-global',
        default_value = 15,
        minimum_value = 1,
        maximum_value = 1440, --- сутки
        localised_name = { 'mt.relations.settings.request.timeout.name' },
        localised_description = { 'mt.relations.settings.request.timeout.description' },
    }
})
