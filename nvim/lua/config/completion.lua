require("nvim-treesitter").install({
	"c_sharp",
	"markdown",
	"markdown_inline",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"cs",
		"markdown",
		"lua",
	},
	callback = function()
		vim.treesitter.start()
	end,
})

local ui = require("config.ui")

require("blink.cmp").setup({
	completion = {
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 100,
			update_delay_ms = 50,
			treesitter_highlighting = true,

			window = {
				max_width = 70,
				max_height = 18,
				scrollbar = true,
				winhighlight = ui.blink.documentation,
			},
		},

		menu = {
			max_height = 12,
			scrollbar = false,

			winhighlight = ui.blink.menu,

			draw = {
				padding = 1,
				gap = 1,
				treesitter = { "lsp" },

				columns = {
					{ "kind_icon" },
					{ "label", "label_description", gap = 1 },
					{ "kind", gap = 1 },
					{ "source_name" },
				},

				components = {
					kind_icon = {
						text = function(ctx)
							if ctx.source_name ~= "Path" then
								return ctx.kind_icon .. ctx.icon_gap
							end

							local data = ctx.item.data or {}
							local filetype = data.type

							local is_unknown_type =
								vim.tbl_contains({ "link", "socket", "fifo", "char", "block", "unknown" }, filetype)

							local mini_icon = require("mini.icons").get(
								is_unknown_type and "os" or filetype,
								is_unknown_type and "" or ctx.label
							)

							return mini_icon or ctx.kind_icon
						end,

						highlight = function(ctx)
							if ctx.source_name ~= "Path" then
								return ctx.kind_hl
							end

							local data = ctx.item.data or {}
							local filetype = data.type

							local is_unknown_type =
								vim.tbl_contains({ "link", "socket", "fifo", "char", "block", "unknown" }, filetype)

							local mini_icon, mini_hl = require("mini.icons").get(
								is_unknown_type and "os" or filetype,
								is_unknown_type and "" or ctx.label
							)

							return mini_icon ~= nil and mini_hl or ctx.kind_hl
						end,
					},

					kind = {
						text = function(ctx)
							return ctx.kind
						end,

						highlight = function(ctx)
							return ctx.kind_hl
						end,
					},

					source_name = {
						text = function(ctx)
							return "[" .. ctx.source_name .. "]"
						end,

						highlight = "Comment",
					},

					label_description = {
						highlight = "Comment",
					},
				},
			},
		},
	},

	sources = {
		default = {
			"lsp",
			"path",
			"snippets",
			"buffer",
		},
	},

	fuzzy = {
		implementation = "prefer_rust_with_warning",
	},

	signature = {
		enabled = true,

		window = {
			max_width = 80,
			max_height = 10,
			scrollbar = false,
			treesitter_highlighting = true,

			winhighlight = ui.blink.signature,
		},
	},
})

local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities({}, false))

capabilities = vim.tbl_deep_extend("force", capabilities, {
	textDocument = {
		foldingRange = {
			dynamicRegistration = false,
			lineFoldingOnly = true,
		},
	},
})

vim.lsp.config("*", {
	capabilities = capabilities,
})
