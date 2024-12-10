data:extend({
  {
    type = "shortcut",
    name = "reset_days_without_incident",
    order = "a[alt-mode]-b[reset-days]",
    action = "lua",
    toggleable = false,
    icon = "__days-without-incident__/icons8-warning-48.png",
    icon_size = 48,
    small_icon = "__days-without-incident__/icons8-warning-16.png",
    small_icon_size = 16,
    associated_control_input = "reset-days-hotkey",
    localised_name = {"days_without_incident.reset"}
  },
  {
    type = "shortcut",
    name = "report_days_without_incident",
    order = "a[alt-mode]-b[report-days]",
    action = "lua",
    toggleable = false,
    icon = "__days-without-incident__/icons8-report-48.png",
    icon_size = 48,
    small_icon = "__days-without-incident__/icons8-report-16.png",
    small_icon_size = 16,
  
    associated_control_input = "report-days-hotkey",
    localised_name = {"days_without_incident.report"}
  }
})
