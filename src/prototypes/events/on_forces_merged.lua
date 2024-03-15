script.on_event(defines.events.on_forces_merged,
    function(event)
        --- Удаляем команду из модуля и сообщаем в чате об этом
        local team = TeamModuleService.getByName(event.source_name)
        TeamModuleService.getAll()[team.name] = nil
        LoggerService.chat({ 'mt.teams.delete.result-by-event', team.title, team.name }, team.color)
    end)
