script.on_event(defines.events.on_player_joined_game, function(event)
    local player = PlayerUtils.getById(event.player_index)

    GuiService.onPlayerJoinedGame(player)

    LoggerService.chat({ 'mt.logger.enabled.notification' }, nil, player)
    LoggerService.debug('Сообщения отладки отображаются. Вы можете скрыть их в своих настройках игрока.')
end)
