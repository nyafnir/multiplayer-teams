---@alias MTOfferInput { eventName: string, playerId: number, localisedMessage: table, timeoutMinutes: number, data: table }

---@alias MTOffer { id: number, eventName: string, playerId: number, localisedMessage: table, expiredAtTicks: number, data: table }

---@alias MTOfferEventResolve { eventName: string, playerId: number, resolve: boolean, data: table }
