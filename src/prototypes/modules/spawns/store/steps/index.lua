local this = {}

-- Шаг для архимеда

function this.get()
    if global.step == nil then
        global.step = spawns.config.archimedeanSpiral.step * 2
    end

    return global.step
end

function this.next()
    local step = this.get()
    step = step + spawns.config.archimedeanSpiral.step
    global.step = step
    return step
end

return this
