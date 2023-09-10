---Возвращает знак числа (на самом деле: 1 или -1).
---@param num number
---@return number
function math.sign(num) -- расширяем дефолтную библиотку math для удобства
    if num < 0 then
        return -1
    else
        return 1
    end
end
