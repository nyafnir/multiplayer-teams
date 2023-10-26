--- Сервис управления предложениями в модуле
OfferModuleService = {}

--- @public
--- Создает предложение для игрока.
--- Ответное событие ждите по переданному вами `eventId` с
--- параметром `event: OfferResolveDto`.
--- @param inputData OfferCreateDto
--- @param needNotify boolean | nil Сообщить в чате о новом предложении в ЛС (по умолчанию: true)
--- @return OfferEntity
function OfferModuleService.create(inputData, needNotify)
    needNotify = needNotify and true or false

    local offer = {
        id = math.random(999999),
        eventId = inputData.eventId,
        playerId = inputData.playerId,
        localisedMessage = inputData.localisedMessage,
        expiredAtTicks = game.ticks_played + TimeUtils.convertMinutesToTicks(inputData.timeoutMinutes),
        data = inputData.data,
    }

    if OfferModuleService.has(inputData.playerId, inputData.eventId) then
        error({ 'mt.offers.errors.offer-already-exist' })
    end

    table.insert(OfferModuleService.getAll(), offer.id, offer)

    if needNotify then
        OfferModuleService.notifyByCreate(offer)
    end

    return offer
end

--- @private
--- Сообщает о новом предложении игроку в чат (ЛС)
--- @param offer OfferEntity
function OfferModuleService.notifyByCreate(offer)
    local player = PlayerUtils.getById(offer.playerId)
    LoggerService.chat(offer.localisedMessage, nil, player)
    LoggerService.chat(
        {
            'mt.offers.resolve.hint',
            offer.id,
            TimeUtils.minutesToClock(
                TimeUtils.convertTicksToMinutes(offer.expiredAtTicks)
            )
        },
        nil,
        player
    )
end

--- @private
--- Проверяет наличие предложения у игрока
--- @param playerId number
--- @param eventId number
--- @return boolean
function OfferModuleService.has(playerId, eventId)
    local offers = OfferModuleService.getAllByPlayer(playerId)

    for _, offer in pairs(offers) do
        if offer.eventId == eventId then
            return true
        end
    end

    return false
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

    for id, offer in pairs(OfferModuleService.getAll()) do
        if offer.playerId == playerId then
            table.insert(offers, id, offer)
        end
    end

    return offers
end

--- @private
--- Возвращает предложение по идентификатору.
--- - Если не найдёт, то выбросит локализованную ошибку.
--- @param id number
function OfferModuleService.getById(id)
    local offer = OfferModuleService.getAll()[id]

    if offer == nil then
        error({ 'mt.offers.errors.offer-not-found' })
    end

    return offer
end

--- @private
--- Удаляет предложение по идентификатору.
--- @param id number | string
function OfferModuleService.deleteById(id)
    OfferModuleService.getAll()[id] = nil
end

--- @private
--- @param offerId number | nil
--- @param playerId number
--- @param resolve boolean
function OfferModuleService.resolve(offerId, playerId, resolve)
    if offerId == nil then
        error({ 'mt.offers.errors.offer-id-required' })
    end

    local offer = OfferModuleService.getById(offerId)

    if offer.playerId ~= playerId then
        error({ 'mt.offers.errors.offer-not-for-you' })
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
