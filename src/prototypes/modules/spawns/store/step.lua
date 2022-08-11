local this = {}

-- Шаг для архимеда

function this.current()
    if global.step == nil then
        global.step = spawns.config.archimedeanSpiral.step * 2
    end

    return global.step
end

function this.next()
    global.step = this.current() + spawns.config.archimedeanSpiral.step
    return global.step
end

return this
