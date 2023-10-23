local context = 'teams'

remote.add_interface(
    ConfigService.prefixes.default .. ':' .. context,
    {
        --- На случай если выключали модуль и манипулировали командами другим модом
        registerAll = function()
            LoggerService.debug('Обновление реестра команд ...')

            local status, result = pcall(TeamModuleService.registerAll, TeamModuleService)
            if status then
                LoggerService.debug('Реестр команд обновлен.')
            else
                LoggerService.debug(result)
            end

            return status
        end
    }
)
