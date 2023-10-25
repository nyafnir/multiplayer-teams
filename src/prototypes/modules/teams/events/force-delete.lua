script.on_event(defines.events.on_forces_merged,
    function(event)
        local team = TeamModuleService.getByName(event.source_name)
        TeamModuleService.getAll()[team.name] = nil
        LoggerService.chat({ 'mt.teams.delete.result-by-event', team.title, team.name }, team.color)
    end)
