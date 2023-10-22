local context = 'teams'

remote.add_interface(
    ConfigService.prefixes.default .. ':' .. context,
    {
        --- На случай если выключали модуль и манипулировали командами другим модом
        registerAll = TeamModuleService.registerAll
    }
)
