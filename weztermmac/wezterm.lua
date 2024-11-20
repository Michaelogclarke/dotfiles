local wezterm = require("wezterm")

local mappings = require "lua.mappings"

local config = wezterm.config_builder()

config.automatically_reload_config = true
config.enable_tab_bar = false
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "RESIZE"
config.color_scheme = 'Catppuccin Mocha'

-- Background
config.window_background_image = "/path/to/your/image.png"
config.window_background_image_hsb = {
  brightness = 0.5,
  hue = 1.0,
  saturation = 1.0,
}
config.window_background_opacity = 0.8


-- keybinds
mappings.apply_to_config(config)

return config

