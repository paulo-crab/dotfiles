require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()
require("mini.extra").setup()
require("mini.git").setup()
require("mini.diff").setup()

local MiniAnimate = require("mini.animate")
MiniAnimate.setup({
	cursor = {
		enable = true,
		timing = MiniAnimate.gen_timing.linear({ duration = 100, unit = "total" }),
	},
	scroll = {
		enable = false,
	},
	resize = { enable = false },
	open = { enable = false },
	close = { enable = false },
})
