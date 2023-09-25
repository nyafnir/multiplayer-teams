TimeUtils = {}

--- @param minutes string | number
--- @return number
function TimeUtils.convertMinutesToTicks(minutes)
    return 60 * 60 * tonumber(minutes)
end

--- @param ticks string | number
--- @return number
function TimeUtils.convertTicksToMinutes(ticks)
    return tonumber(ticks) / 60 / 60
end

--- Вывод оставшегося времени в формате понятном для пользователя.
--- @param minutes number
--- @return string
function TimeUtils.minutesToClock(minutes)
    local hours = string.format("%1.0f", math.floor(minutes / 60));
    local mins = string.format("%1.0f", math.floor(minutes - hours * 60));
    local secs = string.format("%1.0f", math.floor(minutes * 60 - mins * 60 - hours * 3600));

    if minutes >= 60 then
        if mins ~= "0" then
            return hours .. " ч " .. mins .. " мин"
        end

        return hours .. " ч"
    end

    if minutes >= 1 and minutes < 60 then
        if secs ~= "0" then
            return mins .. " мин " .. secs .. ' сек'
        end

        return minutes .. " мин"
    end

    return secs .. ' сек'
end
