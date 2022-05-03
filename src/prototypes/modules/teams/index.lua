local this = {
    model = require('model'),
    store = require('store'),
    events = require('events'),
    commands = require('commands')
}

function this.init()
    if getConfig('teams:enable') then
        this.store.init()

        script.on_event(defines.events.on_player_created, teams.events.onJoinNewPlayer)

        commands.add_command('team', {'teams:help.info'}, teams.commands.info)
        commands.add_command('teams', {'teams:help.list'}, teams.commands.list)
        commands.add_command('team-create', {'teams:help.create'}, teams.commands.create)
        commands.add_command('team-name', {'teams:help.edit-name'}, teams.commands.name)
        commands.add_command('team-color', {'teams:help.edit-color'}, teams.commands.color)
        commands.add_command('team-invite', {'teams:help.invite-send'}, teams.commands.inviteSend)
        commands.add_command('team-invite-accept', {'teams:help.invite-accept'}, teams.commands.inviteAccept)
        commands.add_command('team-invite-cancel', {'teams:help.invite-cancel'}, teams.commands.inviteCancel)
        commands.add_command('team-kick', {'teams:help.kick'}, teams.commands.kick)
        commands.add_command('team-change', {'teams:help.change'}, teams.commands.change)
        commands.add_command('team-remove', {'teams:help.remove'}, teams.commands.remove)
    end
end

function this.load()
    this.store.load()
end

return this
