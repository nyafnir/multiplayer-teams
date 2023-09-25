---Интервально проверяет наличие истёкших предложений и удаляет их
script.on_nth_tick(TimeUtils.convertMinutesToTicks(1), function()
    local list = OfferModuleService.getAll()

    if not next(list) then return end --- если пуст, то игнорируем

    ---@param index number
    ---@param offer OfferEntity
    for index, offer in pairs(list) do
        if offer.expiredAtTicks <= game.ticks_played then
            list[index] = nil --- удаляем истёкшее предложение
        end
    end
end)
