-- Pull in the wezterm API
local wezterm = require 'wezterm'
local mux = wezterm.mux

-- This table will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.front_end = "OpenGL"
config.max_fps = 144
config.default_cursor_style = "BlinkingBlock"
config.animation_fps = 1
config.cursor_blink_rate = 500
config.term = "xterm-256color" -- Set the terminal type

-- For example, changing the color scheme:
config.color_scheme = 'Catppuccin Mocha'

local wsl_domains = wezterm.default_wsl_domains()
local preferred_domains = {
    [1] = 'WSL:archlinux',
    [2] = 'WSL:Ubuntu-24.04',
}
-- Loop through preferred_domains and set the default domain to the first one that matches a domain name in wsl_domains
-- wsl_domains is a list of domains with a name property that is the name of the domain
for _, domain in ipairs(preferred_domains) do
    for _, wsl_domain in ipairs(wsl_domains) do
        if wsl_domain.name == domain then
            config.default_domain = domain
            break
        end
    end
    if config.default_domain then
        break
    end
end

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.window_decorations = 'NONE | RESIZE'
config.window_background_opacity = 0.9
config.audible_bell = "Disabled"
config.window_padding = {
    left = '0.5cell',
    right = '0.5cell',
    top = '0.5cell',
    bottom = '0.5cell',
}

config.keys = {
	{ key = "L", mods = "CTRL", action = wezterm.action.ShowDebugOverlay },
}

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  -- window:gui_window():maximize()
end)

-- and finally, return the configuration to wezterm
return config
