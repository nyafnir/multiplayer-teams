local this = {
    on_offer_resolve = script.generate_event_name()
}

---Интервально проверяем наличие истёкших предложений и удаляем их.
script.on_nth_tick(Utils.time.convertMinutesToTicks(1), function()
    local list = offerModule.service.getOffers()

    if not next(list) then return end

    ---@param index number
    ---@param offer MTOffer
    for index, offer in pairs(list) do
        if offer.expiredAtTicks <= game.ticks_played then
            list[index] = nil
        end
    end
end)

return this
