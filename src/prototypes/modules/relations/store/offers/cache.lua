local this = {
    _vault = {}
}

function this.getAll()
    return this._vault
end

function this.get(ownerToId)
    return this._vault[ownerToId]
end

function this.set(forceFromName, forceToName, ownerToId)

    local obj = {
        forceFromName,
        forceToName,
        expiredAt = game.ticks_played + relations.config.offer.timeout.ticks
    }

    this._vault[ownerToId] = obj

    return obj
end

function this.remove(ownerToId)
    this._vault[ownerToId] = nil
end

return this
