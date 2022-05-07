local this = {
    enable = getConfig('relations:enable'),
    hasFriendlyFire = getConfig('relations:friendly-fire:enable'),
    offer = {
        timeout = {
            minutes = getConfig('relations:offer-timeout'),
            ticks = convertMinutesToTicks(getConfig('relations:offer-timeout'))
        }
    }
}

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if event.setting == getConfigFullName('relations:enable') then
        if this.enable then
            relations.commands.addCmds()
        else
            relations.commands.removeCmds()
        end
    end

    if event.setting == getConfigFullName('relations:friendly-fire:enable') then
        if this.hasFriendlyFire then
            --- Очищаем списки запрета стрельбы, если разрешен
            --- Исключение: игроки без команды
            local defaultName = teams.store.getDefaultForce().name
            for nameFrom, forceFrom in pairs(teams.store.getForces()) do
                if nameFrom ~= defaultName then
                    for nameTo, forceTo in pairs(teams.store.getForces()) do
                        if nameTo ~= defaultName then
                            forceFrom.set_cease_fire(forceTo, false)
                        end
                    end
                end
            end
        end
    end
end)

return this
