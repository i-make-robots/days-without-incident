local days_without_incident = 0
local previous_best = 0

local function report_to_console()
  game.print({"days_without_incident.full-report",days_without_incident, previous_best})
end

-- Update the global variables (used for saving and loading)
local function update_globals() 
  global.days_without_incident = days_without_incident
  global.previous_best = previous_best
end

-- reset the counter
local function reset_counter(player)
  previous_best = math.max(previous_best, days_without_incident)
  player.print({"days_without_incident.an-incident",days_without_incident, previous_best})
  days_without_incident = 0
  update_globals()
end

-- increment the counter every in-game day
local function on_midnight()
  days_without_incident = days_without_incident + 1
  game.print({"days_without_incident.another-day"})
  if previous_best < days_without_incident then
    previous_best = days_without_incident
    game.print({"days_without_incident.new-personal-best"})
  end
  report_to_console()
  update_globals()
end

-- Event when the player presses the shortcut button
script.on_event(defines.events.on_lua_shortcut, function(event)
  if event.prototype_name == "reset_days_without_incident" then
    local player = game.players[event.player_index]
    reset_counter(player)
  end
  if event.prototype_name == "report_days_without_incident" then
    report_to_console()
  end
end)

-- Get ticks per day; if the day/night cycle is always night, return default value of 25000 ticks
local function calculate_day_length(surface)
  -- this could get tricky if there are many planets with different cycle rates.
  return surface.ticks_per_day or 25000
end

-- Event to handle the start of the game and setup the initial state
script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  
  -- Calculate day length based on the game's surface settings
  local day_length = calculate_day_length(player.surface)
  
  -- Set up an on_nth_tick event based on the day length
  script.on_nth_tick(day_length, on_midnight)
end)

-- Event to handle saving and loading of persistent data
script.on_init(function()
  global.days_without_incident = days_without_incident
  global.previous_best = previous_best
end)

script.on_load(function()
  days_without_incident = global.days_without_incident
  previous_best = global.previous_best
end)