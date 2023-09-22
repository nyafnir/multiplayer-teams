ConfigService = {}

ConfigService.prefixes = {
    --- Используется в настройках, локализации и именовании сущностей
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

--- Возвращает значение по ключу (ищет в `startup` и `global`)
--- @param name string Имя без префикса
--- @param isKey? boolean Если префикс уже есть (по умолчанию: false)
function ConfigService.getValue(name, isKey)
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

    return nil
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
