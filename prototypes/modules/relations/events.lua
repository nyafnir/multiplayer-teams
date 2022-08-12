local this = {}

function this.onRemovingForce(event)
    --- Удаляем заявки в эту команду
    relations.store.offers.removeByForceName(event.source.name)
end

return this
