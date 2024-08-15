data:extend({
  {
    type = "shortcut",
    name = "reset_days_without_incident",
    order = "a[alt-mode]-b[reset-days]",
    action = "lua",
    toggleable = false,
    icon =
    {
      filename = "__days-without-incident__/icons8-incident-32.png",
      priority = "extra-high-no-scale",
      size = 32,
      scale = 1,
      flags = {"gui-icon"}
    },
    associated_control_input = "reset-days-hotkey",
    localised_name = {"days_without_incident.reset"}
  },
  {
    type = "shortcut",
    name = "report_days_without_incident",
    order = "a[alt-mode]-b[report-days]",
    action = "lua",
    toggleable = false,
    icon =
    {
      filename = "__days-without-incident__/icons8-report-32.png",
      priority = "extra-high-no-scale",
      size = 32,
      scale = 1,
      flags = {"gui-icon"}
    },
    associated_control_input = "report-days-hotkey",
    localised_name = {"days_without_incident.report"}
  }
})
