require("catppuccin").setup({
	flavour = "catppuccin-macchiato",
})

local dark_theme = "catppuccin-macchiato"
local light_theme = "gruvbox"

local function update_colorscheme()
	if vim.o.background == "light" then
		vim.cmd.colorscheme(light_theme)
	else
		vim.cmd.colorscheme(dark_theme)
	end
end

-- Fix it on start
update_colorscheme()

local colorscheme_group = vim.api.nvim_create_augroup("AutoColorscheme", {
	clear = true,
})

vim.api.nvim_create_autocmd("OptionSet", {
	group = colorscheme_group,
	pattern = "background",
	callback = update_colorscheme,
})
