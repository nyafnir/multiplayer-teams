local this = {
    base = require('base'),
    commands = require('commands')
}

function this.start()
    if getConfig('relations:enable') ~= true then
        return
    end

    -- Если первой консольной команды нет, значит и других нет, тогда загружаем их
    if commands.commands['relations'] == nil then
        commands.add_command('relations', {'relations:help.list'}, relations.commands.list)
        commands.add_command('relation-friend', {'relations:help.friend'}, relations.commands.friend)
        commands.add_command('relation-enemy', {'relations:help.enemy'}, relations.commands.enemy)
        commands.add_command('relation-neutral', {'relations:help.neutral'}, relations.commands.neutral)
    end
end

return this
