--- Сервис управления предложениями в модуле
OfferModuleService = {}

--- Создает предложение для игрока.
--- Ответное событие ждите по переданному вами `eventId` с
--- параметром `event: OfferResolveDto`.
--- @param inputData OfferCreateDto
--- @param needNotify boolean | nil Сообщить в чате о новом предложении в ЛС (по умолчанию: true)
--- @return OfferEntity
function OfferModuleService.create(inputData, needNotify)
    needNotify = needNotify and true or false

    local offer = {
        id = math.random(9999999),
        eventId = inputData.eventId,
        playerId = inputData.playerId,
        localisedMessage = inputData.localisedMessage,
        expiredAtTicks = game.ticks_played + TimeUtils.convertMinutesToTicks(inputData.timeoutMinutes),
        data = inputData.data,
    }
    table.insert(OfferModuleService.getAll(), offer.id, offer)

    if needNotify then
        OfferModuleService.notifyByCreate(offer)
    end

    return offer
end

--- Сообщает о новом предложении игроку в чат (ЛС)
--- @param offer OfferEntity
function OfferModuleService.notifyByCreate(offer)
    local player = PlayerUtils.getById(offer.playerId)
    player.print(offer.localisedMessage)
    player.print(
        {
            ConfigService.getKey('offers.resolve-hint'),
            offer.id,
            TimeUtils.minutesToClock(
                TimeUtils.convertTicksToMinutes(offer.expiredAtTicks)
            )
        },
        player.color
    )
end

--- @private
--- Получить все предложения (имитация базы данных).
--- @return table<number,OfferEntity>
function OfferModuleService.getAll()
    if global.offers == nil then
        --- Создаём объект хранения
        global.offers = {}
    end

    return global.offers
end

--- @private
--- Возвращает список предложений для игрока.
--- @param playerId number
function OfferModuleService.getAllByPlayer(playerId)
    --- @type table<number,OfferEntity>
    local offers = {}

    for _, offer in pairs(OfferModuleService.getAll()) do
        if offer.playerId == playerId then
            table.insert(offers, offer.id, offer)
        end
    end

    return offers
end

--- @private
--- Возвращает предложение по идентификатору.
--- @param id number | string
function OfferModuleService.getById(id)
    return OfferModuleService.getAll()[id]
end

--- @private
--- Удаляет предложение по идентификатору.
--- @param id number | string
function OfferModuleService.deleteById(id)
    if OfferModuleService.getAll()[id] ~= nil then
        OfferModuleService.getAll()[id] = nil
        return true
    end

    return false
end

--- @private
--- @param offerId number | string | nil
--- @param playerId number
--- @param resolve boolean
function OfferModuleService.resolve(offerId, playerId, resolve)
    if offerId == nil then
        error({ ConfigService.getKey('offers.error-offer-id-not-specified') })
    end

    local offer = OfferModuleService.getById(offerId)

    if offer == nil or offer.playerId ~= playerId then
        error({ ConfigService.getKey('offers.error-offer-not-founded') })
    end

    --- @type OfferResolveDto
    local eventData = {
        playerId = offer.playerId,
        resolve = resolve,
        data = offer.data
    }

    OfferModuleService.deleteById(offerId)

    script.raise_event(offer.eventId, eventData)
end
