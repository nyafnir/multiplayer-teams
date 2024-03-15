--- Сервис получения любых настроек
ConfigService = {}

--- @public
ConfigService.prefixes = {
    --- Используется в настройках и именовании сущностей.
    --- @note это название хардкодом вбито в файлы локализации, поэтому
    --- при изменении тут надо менять везде. Так же это название
    --- вбито в DEV-NOTES и стили.
    default = 'mt',
    --- Используется в путях к файлам мода
    filePath = '__MultiplayerTeams__'
}

--- @public
--- Возвращает значение по ключу (ищет в `startup` и `global`).
--- Ожидаемый тип можно задать значением по умолчанию.
--- @param name string Имя без префикса
--- @param isKey? boolean Если префикс уже есть (по умолчанию: false)
--- @generic T :number|boolean|string|Color|nil
--- @param defaultValue? T Значение по умолчанию
--- @return T по умолчанию: unknown, уточняйте типизацией, если без умолчания
function ConfigService.getValue(name, isKey, defaultValue)
    isKey = isKey or false
    local key = isKey and name or ConfigService.getKey(name)

    local startup = settings.startup[key]
    if startup then
        return startup.value
    end

    local runtimeGlobal = settings.global[key]
    if runtimeGlobal then
        return runtimeGlobal.value
    end

    return defaultValue
end

--- @public
--- Получение значения настройки `name` у игрока
--- @param name string
--- @param isKey? boolean Если префикс уже есть (по умолчанию: false)
--- @param playerIndex string | uint
function ConfigService.getValueFor(name, isKey, playerIndex)
    isKey = isKey or false
    local key = isKey and name or ConfigService.getKey(name)

    local runtimePerUser = settings.get_player_settings(playerIndex)[key]
    if runtimePerUser then
        return runtimePerUser.value
    end

    return nil
end

--- @private
--- Объединяет префикс с указанным именем (через двоеточие)
--- @param name string
--- @return string
function ConfigService.getKey(name)
    return ConfigService.prefixes.default .. ':' .. name
end
