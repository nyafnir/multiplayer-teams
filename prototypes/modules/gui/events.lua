local mainButton = require('prototypes.modules.gui.components.main-button.component')

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if event.setting_type ~= 'runtime-global' then
        return
    end

    if event.setting == configService.getKey('gui:enabled') then
        guiModule.config.enabled = configService.get('gui:enabled')
        --- Отлавливаем событие переключения настройки отображения кнопки
        if guiModule.config.enabled then
            mainButton.addForAll()
        else
            mainButton.removeForAll()
        end
    end
end)

--- Добавляем кнопку каждому новому подключенному игроку, если GUI включен
script.on_event(defines.events.on_player_joined_game, function(event)
    if guiModule.config.enabled == true then
        mainButton.addFor(playerService.getById(event.player_index))
    end
end)
