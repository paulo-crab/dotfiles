require("catppuccin").setup({
	flavour = "catppuccin-macchiato",
})

vim.opt.guicursor = table.concat({
	"n-v-c:block-Cursor",
	"i-ci-ve:ver25-Cursor",
	"r-cr:hor20-Cursor",
	"o:hor50-Cursor",
}, ",")

local dark_theme = "catppuccin-macchiato"
local light_theme = "gruvbox"

local function update_colorscheme()
	if vim.o.background == "light" then
		vim.cmd.colorscheme(light_theme)
		vim.api.nvim_set_hl(0, "Cursor", {
			fg = "#3c3836",
			bg = "#d5c4a1",
		})
		vim.api.nvim_set_hl(0, "TermCursor", { fg = "#fbf1c7", bg = "#3c3836" })
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
