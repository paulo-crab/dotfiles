require("mini.icons").mock_nvim_web_devicons()
require("mini.notify").setup()

local statusline = require("mini.statusline")

local function filename_section()
	if vim.bo.filetype == "NvimTree" then
		return " 󰙅 " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
	end

	return statusline.section_filename({ trunc_width = 140 })
end

statusline.setup({
	content = {
		active = function()
			local neovim_icon = ""

			local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
			local git = statusline.section_git({ trunc_width = 40 })
			local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
			local filename = filename_section()
			local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
			local location = statusline.section_location({ trunc_width = 75 })

			local mode_icons = {
				Normal = "󰆾",
				Insert = "󰏫",
				Visual = "󰒉",
				["V-Line"] = "󰒉",
				["V-Block"] = "󰒉",
				Replace = "󰛔",
				Command = "󰘳",
				Terminal = "󰆍",
			}

			local clean_mode = vim.trim(mode)
			local icon = mode_icons[clean_mode] or "󰘳"
			local neovim_icon = ""

			mode = icon .. " " .. mode
			return statusline.combine_groups({
				{ hl = mode_hl, strings = { neovim_icon, mode } },
				{ hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
				"%<",
				{ hl = "MiniStatuslineFilename", strings = { filename } },
				"%=",
				{ hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
				{ hl = mode_hl, strings = { location } },
			})
		end,
	},
})
