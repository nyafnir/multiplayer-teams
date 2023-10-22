--- Сервис получения любых настроек
ConfigService = {}

ConfigService.prefixes = {
    --- Используется в настройках, локализации и именовании сущностей.
    --- Важно: это название хардкодом вбито в файлы локализации, поэтому
    --- при изменении тут надо и менять и там. Так же это название
    --- может быть вбито в DEV-NOTES (примеры).
    default = 'mt',
    --- Используется в путях к файлам мода
    filePath = '__MultiplayerTeams__'
}

--- Объединяет префикс с указанным именем
--- @param name string
--- @return string
function ConfigService.getKey(name)
    return ConfigService.prefixes.default .. ':' .. name
end

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
