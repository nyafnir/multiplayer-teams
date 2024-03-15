require('prototypes.events.on_force_created')
require('prototypes.events.on_forces_merged')
require('prototypes.events.on_player_joined_game')

--- События игры подключаются сюда вместо объявления их локально, так как 
--- работает только один слушатель на каждое событие (видимо какое-то ограничение или баг или перехват).
--- @note это не относится к уникальным событиям модулей и к `script.on_nth_tick`
