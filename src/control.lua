--- Импорты используемые по проекту

require('prototypes.services.config.index')
require('prototypes.services.logger.index')
require('prototypes.services.gui.index')

require('prototypes.utils.color')
require('prototypes.utils.math')
require('prototypes.utils.player')
require('prototypes.utils.string')
require('prototypes.utils.table')
require('prototypes.utils.time')

require('prototypes.events.index')

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
