local this = {
    config = {
        ---@type boolean
        enabled = getConfig('spawns:enabled'),
        --- Архимедова спираль для генерации точек для новых баз
        archimedeanSpiral = {
            ---@type number
            step = getConfig('spawns:archimedean-spiral:step'),
            ---@type number
            distance = getConfig('spawns:archimedean-spiral:distance')
        },
        --- Настройки базы
        options = {
            radius = {
                ---@type number
                near = getConfig('spawns:options:radius:near'),
                ---@type number
                far = getConfig('spawns:options:radius:far')
            },
            --- Смена расположения своей базы
            respawn = {
                --- время в течение которого можно поменять место
                timeout = {
                    ---@type number
                    minutes = getConfig('spawns:options:respawn:timeout'),
                    ---@type number
                    ticks = convertMinutesToTicks(getConfig(
                        'spawns:options:respawn:timeout'))
                }
            },
            --- Добавление ресурсов вокруг базы:
            --- - дубликаты являются отдельными месторождениями
            resources = getConfig('spawns:options:resources')
        }
    },
    store = require('prototypes.modules.spawns.store.index'),
    controller = require('prototypes.modules.spawns.controller'),
    commands = require('prototypes.modules.spawns.commands')
}

local function on_any()
    if this.config.enabled then
        this.commands.init()
    end
end

function this.on_init() on_any() end

function this.on_load() on_any() end

return this
