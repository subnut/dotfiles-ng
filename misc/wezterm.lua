local colorschemes = {
	{ "Colors (base16)", "OneLight (Gogh)" },
}
local colorscheme = colorschemes[1]

local fonts = {
	-- { font name, font_size, line_height, cell_width },
	{ "Victor Mono", 14.5, 0.85, 0.9 },
	{ "Anonymous Pro", 16, 1.0, 0.85 },
	-- Iosevka
	-- 	Term = Ligatures
	-- 	Fixed = No ligatures
	-- style sets -
	-- 	SS15 = IBM Plex
	-- 	SS16 = PT Mono
	{ "Iosevka Term SS15", 14.5, 0.85, 0.9 }, -- ligatures
	{ "Iosevka Fixed SS15", 14.5, 0.85, 0.9 }, -- no ligatures
	{ "Iosevka Term SS16", 14.5, 0.85, 0.9 }, -- ligatures
	{ "Iosevka Fixed SS16", 14.5, 0.85, 0.9 }, -- no ligatures
}
local font = fonts[5]

local wezterm = require 'wezterm'
local light_mode = wezterm.gui.get_appearance():find 'Light'
local color_scheme = wezterm.color.get_builtin_schemes()[colorscheme[light_mode and 2 or 1]]

return {
	window_padding = {
		left = 0, right = 0,
		top = 0, bottom = 0,
	},
	default_prog = { "wsl.exe", "-u", "subnut", "--cd", "~" },

	tab_bar_at_bottom = true,
	use_fancy_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,
	window_decorations = "RESIZE",

	font = wezterm.font(font[1], {}),
	font_size = font[2],
	line_height = font[3],
	cell_width = font[4],

	window_background_opacity = 0.9 + (light_mode and 0.05 or 0),
	color_scheme = colorscheme[light_mode and 2 or 1],
	colors = {
		cursor_fg = wezterm.color.parse(color_scheme.background),
	},

	keys = {
		{ key = 'F11', action = wezterm.action.ToggleFullScreen },
	},
}
