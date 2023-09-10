local this = {}

function this.getOffers()
    if global.offers == nil then
        ---Создаём объект хранения
        global.offers = {}
    end

    return global.offers
end

---@param id number | string
---@return MTOffer | nil
function this.getById(id)
    ---@param offer MTOffer
    for _, offer in ipairs(this.getOffers()) do
        if offer.id == tonumber(id) then return offer end
    end

    return nil
end

---@param id number | string
---@return boolean
function this.removeById(id)
    ---@param offer MTOffer
    for index, offer in ipairs(this.getOffers()) do
        if offer.id == tonumber(id) then
            this.getOffers()[index] = nil
            return true
        end
    end

    return false
end

---@param offerInput MTOfferInput
function this.create(offerInput)
    local offer = {
        id = math.random(9999),
        eventId = offerInput.eventId,
        playerId = offerInput.playerId,
        localisedMessage = offerInput.localisedMessage,
        expiredAtTicks = game.ticks_played + Utils.time.convertMinutesToTicks(offerInput.timeoutMinutes),
        data = offerInput.data,
    }
    table.insert(this.getOffers(), offer)

    local player = playerService.getById(offerInput.playerId)
    player.print(offerInput.localisedMessage)
    player.print({ configService.getKey('offers:common.hint-use'), offer.id,
        Utils.time.minutesToClock(offerInput.timeoutMinutes) }, player.color)
end

---@param requesterId number
function this.list(requesterId)
    local requester = playerService.getById(requesterId)
    local count = 0

    requester.print({ configService.getKey('offers:list.result-header') }, requester.color)

    ---@param offer MTOffer
    for _, offer in pairs(this.getOffers()) do
        if offer.playerId == requesterId then
            count = count + 1
            local timeoutMinutes = Utils.time.convertTicksToMinutes(offer.expiredAtTicks - game.ticks_played)
            requester.print({ configService.getKey('offers:list.result-element'), offer.id,
                Utils.time.minutesToClock(timeoutMinutes),
                offer.localisedMessage },
                requester.color)
        end
    end

    if count == 0 then
        requester.print({ configService.getKey('offers:list.result-empty') }, requester.color)
    end
end

---@param offerId number | string | nil
---@param playerId number
---@param isAccept boolean
local function resolve(offerId, playerId, isAccept)
    if offerId == nil then
        error({ configService.getKey('offers:resolve.error-offer-id-not-specified') })
    end

    local offer = this.getById(offerId)

    if offer == nil then
        error({ configService.getKey('offers:resolve.error-offer-not-founded') })
    end

    if offer.playerId ~= playerId then
        error({ configService.getKey('offers:resolve.error-offer-id-not-owner') })
    end

    local eventData = {
        eventId = offer.eventId,
        playerId = offer.playerId,
        resolve = isAccept,
        data = offer.data
    }

    script.raise_event(offerModule.events.onMTOfferResolve, eventData)

    this.removeById(offerId)
end

---@param offerId number | string | nil
---@param playerId number
function this.accept(offerId, playerId)
    resolve(offerId, playerId, true)
end

---@param offerId number | string | nil
---@param playerId number
function this.cancel(offerId, playerId)
    resolve(offerId, playerId, false)
end

return this
