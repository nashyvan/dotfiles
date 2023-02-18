-- set colorscheme to nightfly with protected call
-- in case it isn't installed
-- nightfly onedark everforest kanagawa darcula darcula-solid
local status, _ = pcall(vim.cmd, "colorscheme darcula-solid")
if not status then
	print("Colorscheme not found!") -- print error if colorscheme not installed
	return
end
