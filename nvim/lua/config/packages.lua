require("config.utils")

PackAdd("nvim-mini/mini.nvim")
PackAdd("mason-org/mason.nvim")

PackAdd("dmtrKovalenko/fff")
PackAdd("nvim-tree/nvim-tree.lua")

PackAdd("stevearc/conform.nvim", "stable")
PackAdd("saghen/blink.cmp", "v1.*")
PackAdd("onsails/lspkind.nvim")
-- PackAdd("nvim-treesitter/nvim-treesitter")

-- UI
PackAdd("catppuccin/nvim")
PackAdd("ellisonleao/gruvbox.nvim")
PackAdd("folke/which-key.nvim")

---- For FFF
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind

		if name == "fff" and (kind == "install" or kind == "update") then
			if not ev.data.active then
				vim.cmd.packadd("fff")
			end

			require("fff.download").download_or_build_binary()
		end
	end,
})
