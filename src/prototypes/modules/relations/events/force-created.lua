script.on_event(defines.events.on_force_created,
    function(event)
        --- Запрещаем автоматическую стрельбу в команды по умолчанию, кроме кусак
        RelationModuleService.setNeutral(event.force, game.forces[DEFAULT_TEAM_NAME])
        RelationModuleService.setNeutral(event.force, game.forces[NEUTRAL_TEAM_NAME])
    end)
