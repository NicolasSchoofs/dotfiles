local wezterm = require("wezterm")
local act = wezterm.action

return {
  -- ========================
  -- Appearance
  -- ========================

  -- for tilde
  send_composed_key_when_left_alt_is_pressed = true,

  -- Background transparency
  window_background_opacity = 0.95,

  -- macOS blur (looks great with transparency)
  macos_window_background_blur = 20,

  -- Color scheme (change if you want)
  color_scheme = "Tokyo Night Moon",

  -- Font
  font = wezterm.font("JetBrains Mono"),
  font_size = 14,

  -- Padding
  window_padding = {
    left = 10,
    right = 10,
    top = 10,
    bottom = 10,
  },

  -- ========================
  -- Tabs
  -- ========================

  enable_tab_bar = true,

  -- Move tabs to the bottom
  tab_bar_at_bottom = true,

  -- Optional: hide tab bar when only one tab
  hide_tab_bar_if_only_one_tab = false,

  -- Cleaner tab look
  use_fancy_tab_bar = false,

  -- ========================
  -- Keybindings
  -- ========================


  keys = {
    -- New tab
    {
      key = "t",
      mods = "CMD",
      action = act.SpawnTab("CurrentPaneDomain"),
    },

    -- Close current tab
    {
      key = "w",
      mods = "CMD",
      action = act.CloseCurrentTab({ confirm = true }),
    },

    -- Move to tab on the left
    {
      key = "LeftArrow",
      mods = "CMD|ALT",
      action = act.ActivateTabRelative(-1),
    },

    -- Move to tab on the right
    {
      key = "RightArrow",
      mods = "CMD|ALT",
            action = act.ActivateTabRelative(1),
        },
    },

}

