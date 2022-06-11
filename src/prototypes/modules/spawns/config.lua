return {
    enable = getConfig('spawns:enable'),
    respawn = {
        timeout = {
            minutes = getConfig('spawns:respawn-timeout'),
            ticks = convertMinutesToTicks(getConfig('spawns:respawn-timeout'))
        }
    },
    archimedeanSpiral = {
        distance = getConfig('spawns:archimedean-spiral:distance'),
        step = getConfig('spawns:archimedean-spiral:step')
    },
    base = {
        internalRadius = getConfig('spawns:base:internal-radius'),
        externalRadius = getConfig('spawns:base:external-radius')
    }
}
