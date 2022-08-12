return {
    enable = getConfig('relations:enable'),
    offer = {
        timeout = {
            minutes = getConfig('relations:offer-timeout'),
            ticks = convertMinutesToTicks(getConfig('relations:offer-timeout'))
        }
    }
}
