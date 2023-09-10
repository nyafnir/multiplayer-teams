local this = {
    onMTRelationOfferResolve = script.generate_event_name()
}

script.on_event(this.onMTRelationOfferResolve,
    ---@param event MTOfferEventResolve
    function(event)
        ---@type { teamName: string, type: 'neutral' | 'friend' }
        local data = event.data

        local team = teamModule.service.getByName(data.teamName)
        ---Проверяем, что команда которая предлагала существует
        if team == nil then
            return
        end
        local owner = playerService.getById(team.ownerId)

        local otherOwner = playerService.getById(event.playerId)
        local otherTeam = teamModule.service.getByName(otherOwner.force.name)

        if data.type == 'neutral' then
            if event.resolve then
                -- вражда
                owner.force.set_friend(otherOwner.force, false)
                otherOwner.force.set_friend(owner.force, false)
                -- не стреляют по друг другу
                owner.force.set_cease_fire(otherOwner.force, true)
                otherOwner.force.set_cease_fire(owner.force, true)

                return game.print({ configService.getKey('relations:set:neutral.result-accept'), team.title,
                    otherTeam.title },
                    colorService.list.white)
            else
                return game.print({ configService.getKey('relations:set:neutral.result-cancel'), otherTeam.title,
                    team.title }
                    , otherTeam.color)
            end
        end

        if data.type == 'friend' then
            if event.resolve then
                -- союз
                owner.force.set_friend(otherOwner.force, true)
                otherOwner.force.set_friend(owner.force, true)
                -- не стреляют по друг другу
                owner.force.set_cease_fire(otherOwner.force, true)
                otherOwner.force.set_cease_fire(owner.force, true)

                return game.print({ configService.getKey('relations:set:friend.result-accept'), team.title,
                    otherTeam.title },
                    colorService.list.white)
            else
                return game.print({ configService.getKey('relations:set:friend.result-cancel'), otherTeam.title }
                    , otherTeam.color)
            end
        end
    end)

return this
