return {
	"saghen/blink.cmp",
	version = "1.*",
	cond = vim.g.vscode == nil,
	-- Load early enough so LSP can pull capabilities on BufReadPre.
	-- "InsertEnter" alone is too late — blink wouldn't be ready when
	-- nvim-lspconfig fires and calls get_lsp_capabilities().
	lazy = false,
	dependencies = { "fang2hou/blink-copilot" },
	opts = {
		keymap = {
			preset = "default",
			["<Tab>"] = {
				"snippet_forward",
				function() -- sidekick next edit suggestion
					return require("sidekick").nes_jump_or_apply()
				end,
				"fallback",
			},
		},
		appearance = {
			nerd_font_variant = "mono",
		},
		signature = {
			enabled = true,
			window = {
				border = "rounded",
			},
		},
		completion = {
			menu = {
				border = "rounded",
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 500,
				window = { border = "rounded" },
			},
			ghost_text = {
				enabled = true,
			},
		},
		sources = {
			default = { "lsp", "copilot", "path", "snippets", "buffer" },
			providers = {
				copilot = {
					name = "copilot",
					module = "blink-copilot",
					async = true,
					score_offset = 100, -- ensure copilot items rank above buffer text
				},
			},
		},
		fuzzy = { implementation = "lua" },
	},
	opts_extend = { "sources.default" },
}
