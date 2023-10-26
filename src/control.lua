--- Импорты используемые по проекту
--- Порядок зависит от использования одного модуля другим

require('prototypes.services.config.index')
require('prototypes.services.logger.index')

require('prototypes.utils.color')
require('prototypes.utils.math')
require('prototypes.utils.player')
require('prototypes.utils.string')
require('prototypes.utils.table')
require('prototypes.utils.time')

require('prototypes.modules.offers.index')
require('prototypes.modules.teams.index')
require('prototypes.modules.relations.index')

--- [Событие] Происходит после создания карты с включенным модом
script.on_init(function()
    TeamModuleService.registerAll()
end)

--- [Событие] Происходит после загрузки и сохранения
--- Нет доступа к изменению `global`!
script.on_load(function()
end)

--- Проверка работоспособности логгера, событие при присоединении игрока
script.on_event(defines.events.on_player_joined_game, function(event)
    local player = PlayerUtils.getById(event.player_index)
    LoggerService.chat({ 'mt.logger.enabled.notification' }, nil, player)
    LoggerService.debug('Сообщения отладки отображаются. Вы можете скрыть их в своих настройках игрока.')
end)
