local fonts = {
	'Victor Mono',
}
local font = fonts[1]

local light_mode = true -- and false
local colorschemes = {
	{ "Monokai", "OneLight (Gogh)" },
}
local colorscheme = colorschemes[1]
local cursorfg = { 'black', 'white' }

local wezterm = require 'wezterm'
return {
	font_size = 14.5,
	line_height = 0.9,
	window_padding = {
		left = 0, right = 0,
		top = 0, bottom = 0,
	},
	default_prog = { "wsl.exe", "-u", "subnut", "--cd", "~" },
	color_scheme = colorscheme[light_mode and 2 or 1],
	colors = { cursor_fg = cursorfg[light_mode and 2 or 1] },
	window_background_opacity = 0.9 + (light_mode and 0.05 or 0),
	font = wezterm.font(font, {}),

	tab_bar_at_bottom = true,
	use_fancy_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,
	window_decorations = "RESIZE",

	keys = {
		{ key = 'F11', action = wezterm.action.ToggleFullScreen },
	},
}
