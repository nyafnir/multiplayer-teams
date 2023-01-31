local this = {}

script.on_event(offerModule.events.on_offer_resolve,
    ---@param event MTOfferEventResolve
    function(event)
        if event.eventName ~= 'relation_offer' then
            return
        end

        ---@type { teamName: string, type: 'neutral' | 'friend' }
        local data = event.data

        local team = teamModule.service.getByName(data.teamName)
        ---Проверяем, что команда которая предлагала существует
        if team == nil then
            return
        end
        local owner = playerService.getById(team.ownerId)

        local otherTeam = teamModule.service.getByName(team.name)
        ---Проверяем, что команда которая цель существует
        if otherTeam == nil then
            return
        end
        local otherOwner = playerService.getById(event.playerId)

        if data.type == 'neutral' then
            if event.resolve then
                owner.force.set_friend(otherOwner.force, false)
                owner.force.set_cease_fire(otherOwner.force, false)

                return game.print({ configService.getKey('relations:set:neutral.result-accept'), team.title,
                    otherTeam.title },
                    colorService.list.white)
            else
                return owner.force.print({ configService.getKey('relations:set:neutral.result-cancel'), otherTeam.title }
                    , otherTeam.color)
            end
        end

        if data.type == 'friend' then
            if event.resolve then
                owner.force.set_friend(otherOwner.force, true)
                owner.force.set_cease_fire(otherOwner.force, false)

                return game.print({ configService.getKey('relations:set:friend.result-accept'), team.title,
                    otherTeam.title },
                    colorService.list.white)
            else
                return owner.force.print({ configService.getKey('relations:set:friend.result-cancel'), otherTeam.title }
                    , otherTeam.color)
            end
        end
    end)

return this
