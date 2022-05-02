local this = {
    model = require('model'),
    store = require('store'),
    events = require('events'),
    commands = require('commands')
}

function this:init()
    this.store.init()
end

function this:load()
    this.store.load()
end

return this
