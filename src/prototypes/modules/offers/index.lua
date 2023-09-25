require('prototypes.modules.offers.dtos.create-offer')
require('prototypes.modules.offers.dtos.resolve-offer')
require('prototypes.modules.offers.entities.offer')
require('prototypes.modules.offers.service')
require('prototypes.modules.offers.commands')
require('prototypes.modules.offers.events.delete-expired')

--- Модуль предложений.
--- Позволяет отправлять предложения игроками (со сроком действия и с любыми
--- данными) и получать ответ игрока событием.
