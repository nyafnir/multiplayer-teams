local this = {}

function this.onRemovingForce(event)
    --- удаляем заявки в эту команду
    relations.store.offers.removeByForceName(event.source.name)
end

return this
