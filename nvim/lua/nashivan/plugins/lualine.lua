-- import lualine plugin safely
local status, lualine = pcall(require, "lualine")
if not status then
	return
end

-- get lualine nightfly, kanagawa theme
local lualine_nightfly = require("lualine.themes.nightfly")
-- local lualine_kanagawa = require("lualine.themes.kanagawa")

-- new colors for theme
local new_colors = {
	bg = "#262627",
	nvimtree = "#2f3032",
	blue = "#5594EC",
	green = "#8FA867",
	violet = "#A781BB",
	yellow = "#FFC66B",
	black = "#000000",
}

-- change nightlfy theme colors
lualine_nightfly.inactive.a.bg = new_colors.nvimtree
lualine_nightfly.inactive.b.bg = new_colors.nvimtree
lualine_nightfly.inactive.c.bg = new_colors.nvimtree
lualine_nightfly.normal.c.bg = new_colors.bg
lualine_nightfly.visual.b.bg = new_colors.bg
lualine_nightfly.insert.b.bg = new_colors.bg
lualine_nightfly.normal.a.bg = new_colors.blue
lualine_nightfly.insert.a.bg = new_colors.green
lualine_nightfly.visual.a.bg = new_colors.violet
lualine_nightfly.command = {
	a = {
		gui = "bold",
		bg = new_colors.yellow,
		fg = new_colors.black, -- black
	},
}

-- configure lualine with modified theme
lualine.setup({
	options = {
		theme = lualine_nightfly,
	},
})
