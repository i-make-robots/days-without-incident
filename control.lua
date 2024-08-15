-- Counters should be kept in global, no reason to make a local variable for this
-- local days_without_incident = 0
-- local previous_best = 0
local function report_to_console(surface_index)
  local s = global.surfaces[surface_index]

  game.print({ "days_without_incident.full-report", s.days_without_incident, s.previous_best, s.name }) -- Adding surface
end

-- Update the global variables (used for saving and loading)
-- No longer required
-- local function update_globals(surface_index)
--     global.surfaces[surface_index].days_without_incident = days_without_incident
--     global.surfaces[surface_index].previous_best = previous_best
-- end

-- reset the counter
local function reset_counter(player)
  -- Check if there is a surface
  if not player.surface then
    game.print("Player " .. player.name .. " is not on any surface, unable to report incident")
    return
  end

  -- Update directly in global
  local s = global.surfaces[player.surface.index]
  s.previous_best = math.max(s.previous_best, s.days_without_incident)
  player.print({ "days_without_incident.an-incident", s.days_without_incident, s.previous_best, s.name }) -- Adding surface
  s.days_without_incident = 0
end

-- increment the counter every in-game day
local function on_midnight(surface_index)
  -- Get the global surface
  local s = global.surfaces[surface_index]

  -- Update stats
  s.days_without_incident = s.days_without_incident + 1
  game.print({ "days_without_incident.another-day", s.name }) -- Adding surface

  if s.previous_best < s.days_without_incident then
    s.previous_best = s.days_without_incident
    game.print({ "days_without_incident.new-personal-best" })
  end
  report_to_console(surface_index)
end

-- Event when the player presses the shortcut button
script.on_event(defines.events.on_lua_shortcut, function(event)
  local player = game.get_player(event.player_index)
  if not player then
    return
  end

  if event.prototype_name == "reset_days_without_incident" then
    -- local player = game.players[event.player_index] --This does not work as you never init/set game.players
    reset_counter(player)
  end
  if event.prototype_name == "report_days_without_incident" and player.surface then
    report_to_console(player.surface.index)
  end
end)

-- Get ticks per day; if the day/night cycle is always night, return default value of 25000 ticks
local function calculate_day_length(surface)
  -- this could get tricky if there are many planets with different cycle rates.
  return surface.ticks_per_day or 25000
end

-- Event to handle the start of the game and setup the initial state
script.on_event(defines.events.on_player_created, function(event)
  -- Migrated to init_surface and on_tick
end)

local function init_surface(surface_index)
  -- Early exit in case the first game surface triggers before on_init, or if we didn't find the surface in game
  local surface = game.get_surface(surface_index)
  if not global.surfaces or not surface then
    return
  end

  -- You might need to create some additional logic to ignore "subsurfaces" e.g. from SE's pyramid or from factorissimo

  -- Init the current surface array
  if not global.surfaces[surface_index] then
    global.surfaces[surface_index] = {}
  end
  local s = global.surfaces[surface_index]

  -- Init individual parameters
  s.days_without_incident = s.days_without_incident or 0
  s.previous_best = s.previous_best or 0
  s.name = surface.name

  -- Calculate day length based on the game's surface settings
  s.day_length = calculate_day_length(surface)
  s.ticks_since_last_day = 0
end

local function init_surfaces()
  -- Init global.surfaces
  if not global.surfaces then
    global.surfaces = {}
  end

  -- Init each surface
  for _, s in pairs(game.surfaces) do
    init_surface(s.index)
  end
end

-- Event to handle saving and loading of persistent data
script.on_init(function()
  init_surfaces()
end)
script.on_configuration_changed(function()
  -- When a mod configuration changes (e.g. new version) then saves that already include this mod do not re-run on_init but on_configuration_changed, so we need to make sure that old saves also get the proper global initialized
  init_surfaces()
end)

script.on_event(defines.events.on_surface_created, function(e)
  init_surface(e.surface_index)
  game.print({ "days-without-incident.new-surface", game.get_surface(e.surface_index).name })
end)

script.on_event(defines.events.on_tick, function(e)
  -- Midnight handler per global surface
  for i, s in pairs(global.surfaces) do
    -- Get the surface
    local surface = game.get_surface(i)
    if surface then
      -- Determine midnight
      if surface.always_day then
        -- Manual tick counting for surfaces that are always day
        s.ticks_since_last_day = s.ticks_since_last_day + 1
        if s.ticks_since_last_day > 25000 then
          s.ticks_since_last_day = 0
          on_midnight(i)
        end
      else
        -- game.print("tick update for " .. s.name .. ", daytime = " .. surface.daytime)
        -- Use daytime property
        -- Remember last tick's daytime and current daytime
        s.previous_daytime = s.daytime or 0
        s.daytime = surface.daytime
        if s.previous_daytime > s.daytime then
          -- If the last tick's daytime is bigger than the current tick's daytime it means we have a new day
          on_midnight(i)

          -- Update the global.surface ticks per day, since it could be that other mods have updated it in the meantime
          s.ticks_per_day = surface.ticks_per_day
        end
      end
    end
  end
end)

script.on_load(function()
  -- Counters should be kept in global, no reason to make a local variable for this
end)
