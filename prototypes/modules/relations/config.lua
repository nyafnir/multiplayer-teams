return {
    enabled = getConfig('relations:enabled'),
    offer = {
        timeout = {
            minutes = getConfig('relations:offer-timeout'),
            ticks = convertMinutesToTicks(getConfig('relations:offer-timeout'))
        }
    }
}
