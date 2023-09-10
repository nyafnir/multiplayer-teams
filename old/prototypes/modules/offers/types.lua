---@alias MTOfferInput { eventId: number, playerId: number, localisedMessage: table, timeoutMinutes: number, data: table }

---@alias MTOffer { id: number, eventId: number, playerId: number, localisedMessage: table, expiredAtTicks: number, data: table }

---@alias MTOfferEventResolve { eventId: number, playerId: number, resolve: boolean, data: table }
