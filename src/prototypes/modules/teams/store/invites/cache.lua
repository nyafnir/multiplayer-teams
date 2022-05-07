local this = {
    _vault = {}
}

function this.getAll()
    return this._vault
end

function this.get(playerToId)
    return this._vault[playerToId]
end

function this.set(forceFromName, playerToId)

    local obj = {
        forceFromName = forceFromName,
        expiredAt = game.ticks_played + teams.config.invites.timeout.ticks
    }

    this._vault[playerToId] = obj

    return obj
end

function this.remove(playerToId)
    this._vault[playerToId] = nil
end

return this
