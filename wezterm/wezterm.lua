--- wezterm.lua
--- $ figlet -f small Wezterm
--- __      __      _
--- \ \    / /__ __| |_ ___ _ _ _ __
---  \ \/\/ / -_)_ /  _/ -_) '_| '  \
---   \_/\_/\___/__|\__\___|_| |_|_|_|
---
--- My Wezterm config file

local wezterm = require("wezterm")
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local act = wezterm.action

-- local fish_path = "/opt/homebrew/bin/fish"

local config = {}
-- Use config builder object if possible
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Settings
config.default_prog = { "/bin/zsh" }
config.term = "wezterm"

config.color_scheme = "vscode-dark"
config.colors = {
	background = '#1c1c1c',
	tab_bar = {
		active_tab = {
			bg_color = '#1f1f1f',
			fg_color = '#c0c0c0',
		},
	},
}

config.font = wezterm.font_with_fallback({
	{ family = "JetbrainsMono Nerd Font",  scale = 1.2, weight = "Bold" },
	{ family = "Iosevka Nerd Font",        scale = 1.2, weight = "Medium" },
	{ family = "FantasqueSansM Nerd Font", scale = 1.3 },
})
-- config.window_background_opacity = 0.95
config.window_decorations = "RESIZE" -- |TITLE|INTEGRATED_BUTTONS
config.window_close_confirmation = "NeverPrompt"
config.scrollback_lines = 5000
config.default_workspace = "main"

-- Dim inactive panes
config.inactive_pane_hsb = {
	saturation = 0.24,
	brightness = 0.5,
}

-- Keys
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{
		key = "R",
		mods = "LEADER|SHIFT",
		-- action = act.ReloadConfiguration,
		action = wezterm.action_callback(function(window, pane)
			window:set_right_status("✅ Reloaded config!")
			window:perform_action(wezterm.action.ReloadConfiguration, pane)
		end),
	},
	{
		key = "o",
		mods = "CMD",
		action = wezterm.action.EmitEvent("trigger-test-overlay"),
	},
	{ key = 'L',          mods = 'CTRL',        action = wezterm.action.ShowDebugOverlay },

	-- Send C-a when pressing C-a twice
	{ key = "a",          mods = "LEADER|CTRL", action = act.SendKey({ key = "a", mods = "CTRL" }) },
	{ key = "c",          mods = "LEADER",      action = act.ActivateCopyMode },
	{ key = "phys:Space", mods = "LEADER",      action = act.ActivateCommandPalette },

	-- Pane keybindings
	{ key = "s",          mods = "LEADER",      action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "v",          mods = "LEADER",      action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "h",          mods = "LEADER",      action = act.ActivatePaneDirection("Left") },
	{ key = "j",          mods = "LEADER",      action = act.ActivatePaneDirection("Down") },
	{ key = "k",          mods = "LEADER",      action = act.ActivatePaneDirection("Up") },
	{ key = "l",          mods = "LEADER",      action = act.ActivatePaneDirection("Right") },
	{ key = "q",          mods = "LEADER",      action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "z",          mods = "LEADER",      action = act.TogglePaneZoomState },
	{ key = "o",          mods = "LEADER",      action = act.RotatePanes("Clockwise") },
	-- We can make separate keybindings for resizing panes
	-- But Wezterm offers custom "mode" in the name of "KeyTable"
	{
		key = "r",
		mods = "LEADER",
		action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }),
	},

	-- Tab keybindings
	{ key = "t", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },
	{ key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },
	{ key = "n", mods = "LEADER", action = act.ShowTabNavigator },
	{
		key = "e",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Renaming Tab Title...:" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	-- Key table for moving tabs around
	{ key = "m", mods = "LEADER",       action = act.ActivateKeyTable({ name = "move_tab", one_shot = false }) },
	-- Or shortcuts to move tab w/o move_tab table. SHIFT is for when caps lock is on
	{ key = "{", mods = "LEADER|SHIFT", action = act.MoveTabRelative(-1) },
	{ key = "}", mods = "LEADER|SHIFT", action = act.MoveTabRelative(1) },

	{
		key = "f",
		mods = "CMD|CTRL",
		action = wezterm.action.ToggleFullScreen,
	},
	-- Lastly, workspace
	{ key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
	-- {
	-- 	key = "s",
	-- 	mods = "CMD",
	-- 	action = wezterm.action_callback(function(win, pane)
	-- 		resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
	-- 		resurrect.window_state.save_window_action()(win, pane)
	-- 		win:set_right_status("✅ Reloaded config!")
	-- 		win:perform_action(
	-- 			wezterm.action.EmitEvent("save-session"),
	-- 			pane
	-- 		)
	-- 	end),
	{
		key = "s",
		mods = "CMD",
		action = wezterm.action_callback(function(win, pane)
			-- First, show the status message
			win:set_right_status("💾 Session saved!")

			-- Clear the status message after 1.5 seconds
			-- wezterm.time.call_after(1.5, function()
			-- 	win:set_right_status("")
			-- end)

			-- Perform saving actions with a slight delay to let the UI update
			wezterm.time.call_after(0.01, function()
				resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
				resurrect.window_state.save_window_action()(win, pane)
				win:perform_action(
					wezterm.action.EmitEvent("save-session"),
					pane
				)
			end)
		end),
	},
	{
		key = "r",
		mods = "CMD",
		action = wezterm.action_callback(function(win, pane)
			resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
				local type = string.match(id, "^([^/]+)")
				id = string.match(id, "([^/]+)$")
				id = string.match(id, "(.+)%..+$")
				local opts = {
					relative = true,
					restore_text = true,
					on_pane_restore = resurrect.tab_state.default_on_pane_restore,
				}
				if type == "workspace" then
					local state = resurrect.state_manager.load_state(id, "workspace")
					resurrect.workspace_state.restore_workspace(state, opts)
				elseif type == "window" then
					local state = resurrect.state_manager.load_state(id, "window")
					resurrect.window_state.restore_window(pane:window(), state, opts)
				elseif type == "tab" then
					local state = resurrect.state_manager.load_state(id, "tab")
					resurrect.tab_state.restore_tab(pane:tab(), state, opts)
				end
			end)
		end),
	},
}
-- I can use the tab navigator (LDR t), but I also want to quickly navigate tabs with index
for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = act.ActivateTab(i - 1),
	})
end

config.key_tables = {
	resize_pane = {
		{ key = "h",      action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "j",      action = act.AdjustPaneSize({ "Down", 1 }) },
		{ key = "k",      action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "l",      action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter",  action = "PopKeyTable" },
	},
	move_tab = {
		{ key = "h",      action = act.MoveTabRelative(-1) },
		{ key = "j",      action = act.MoveTabRelative(-1) },
		{ key = "k",      action = act.MoveTabRelative(1) },
		{ key = "l",      action = act.MoveTabRelative(1) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter",  action = "PopKeyTable" },
	},
}

-- Tab bar
-- I don't like the look of "fancy" tab bar
config.use_fancy_tab_bar = false
config.status_update_interval = 1000
config.tab_max_width = 50
config.tab_bar_at_bottom = false
wezterm.on("gui-startup", resurrect.state_manager.resurrect_on_gui_startup)
resurrect.state_manager.periodic_save({
	interval_seconds = 300,
	save_tabs = true,
	save_windows = true,
	save_workspaces = true,
})
resurrect.state_manager.set_max_nlines(5000)
wezterm.on("update-status", function(window, pane)
	-- Workspace name
	local stat = window:active_workspace()
	local stat_color = "#ffffff"
	-- It's a little silly to have workspace name all the time
	-- Utilize this to display LDR or current key table name
	if window:active_key_table() then
		stat = window:active_key_table()
		stat_color = "#7dcfff"
	end
	if window:leader_is_active() then
		stat = "LDR"
		stat_color = "#bb9af7"
	end

	local basename = function(s)
		-- Nothing a little regex can't fix
		return string.gsub(s, "(.*[/\\])(.*)", "%2")
	end

	-- Current working directory
	local cwd = pane:get_current_working_dir()
	if cwd then
		if type(cwd) == "userdata" then
			-- Wezterm introduced the URL object in 20240127-113634-bbcac864
			cwd = basename(cwd.file_path)
		else
			-- 20230712-072601-f4abf8fd or earlier version
			cwd = basename(cwd)
		end
	else
		cwd = ""
	end

	-- Current command
	local cmd = pane:get_foreground_process_name()
	-- CWD and CMD could be nil (e.g. viewing log using Ctrl-Alt-l)
	cmd = cmd and basename(cmd) or ""

	-- Time
	local time = wezterm.strftime("%H:%M")

	-- Left status (left of the tab line)
	window:set_left_status(wezterm.format({
		{ Foreground = { Color = stat_color } },
		{ Text = "  " },
		{ Text = wezterm.nerdfonts.oct_table .. "  " .. stat },
		{ Text = " |" },
	}))

	-- Right status
	window:set_right_status(wezterm.format({
		-- Wezterm has a built-in nerd fonts
		-- https://wezfurlong.org/wezterm/config/lua/wezterm/nerdfonts.html
		{ Text = wezterm.nerdfonts.md_folder .. "  " .. cwd },
		{ Text = " | " },
		-- { Foreground = { Color = "#e0af68" } },
		{ Text = wezterm.nerdfonts.fa_code .. "  " .. cmd },
		-- "ResetAttributes",
		-- { Text = " | " },
		-- { Text = wezterm.nerdfonts.md_clock .. "  " .. time },
		{ Text = "  " },
	}))
end)

--[[ Appearance setting for when I need to take pretty screenshots
config.enable_tab_bar = false
config.window_padding = {
  left = '0.5cell',
  right = '0.5cell',
  top = '0.5cell',
  bottom = '0cell',

}
--]]

return config
