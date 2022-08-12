local this = {
    _vault = {}
}

function this.getAll()
    return this._vault
end

function this.get(playerToId)
    return this.getAll()[playerToId]
end

function this.set(forceFromName, playerToId)

    local obj = {
        forceFromName = forceFromName,
        expiredAt = game.ticks_played + teams.config.invite.timeout.ticks
    }

    this.getAll()[playerToId] = obj

    return obj
end

function this.remove(playerToId)
    this.getAll()[playerToId] = nil
end

function this.removeByForceName(forceName)
    for playerToId, obj in pairs(this.getAll()) do
        if obj.forceFromName == forceName then
            this.remove(playerToId)
        end
    end
end

return this
