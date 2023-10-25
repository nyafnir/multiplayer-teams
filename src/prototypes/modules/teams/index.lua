require('prototypes.modules.teams.dtos.invite-data')
require('prototypes.modules.teams.entities.team')
require('prototypes.modules.teams.service')
require('prototypes.modules.teams.remotes')
require('prototypes.modules.teams.commands')
require('prototypes.modules.teams.constants')
require('prototypes.modules.teams.events.force-delete')
require('prototypes.modules.teams.events.resolve-invite')

--- Модуль команд.
--- Позволяет игрокам создавать команды и управлять ими.
--- @note у игрока всегда есть команда, не может быть игрока без команды.
--- @note важно различать team name (имя) и team title (название), название можно менять, а имя нет.
--- Для приглашений использует модуль `offers`.
--- Для отношений между командами используется в модуле `relations`.
--- Для местоположения используется в модуле `spawns`.
--- Для экономики используется в модуле `economy`.
--- Для заданий используется в модуле `quests` + `economy`.
