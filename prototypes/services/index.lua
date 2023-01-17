---@diagnostic disable: lowercase-global

configService = require('prototypes.services.config')
loggerService = require('prototypes.services.logger.service') -- использует `configService` и `Utils`
colorService = require('prototypes.services.color')
playerService = require('prototypes.services.player')
