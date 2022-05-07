local this = {
    enable = getConfig('relations:enable'),
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
end)

return this
