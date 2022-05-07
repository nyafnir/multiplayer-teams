return {
    enable = getConfig('teams:enable'),
    invite = {
        timeout = {
            minutes = getConfig('teams:invite-timeout'),
            ticks = convertMinutesToTicks(getConfig('teams:invite-timeout'))
        }
    },
    default = {
        forces = {'player', 'enemy', 'neutral'}, -- создаются игрой автоматический
        forceName = 'player'
    }
}
