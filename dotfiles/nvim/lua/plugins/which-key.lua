return {
	"folke/which-key.nvim",
	cond = vim.g.vscode == nil,
	event = "VeryLazy",
	config = function()
		local wk = require("which-key")
		wk.setup({
			preset = "helix",
			show_help = false,
			show_keys = false,
		})
		wk.add({
			mode = { "n", "v" },
			{ "<leader><tab>", group = "tabs" },
			{ "<leader>a", group = "ai" },
			{ "<leader>b", group = "buffer" },
			{ "<leader>c", group = "code" },
			{ "<leader>f", group = "file/find" },
			{ "<leader>g", group = "git" },
			{ "<leader>gd", group = "diffview" },
			{ "<leader>gh", group = "hunks" },
			{ "<leader>l", desc = "Lazy" },
			{ "<leader>n", desc = "Notification History" },
			{ "<leader>p", desc = "Clipboard History" },
			{ "<leader>r", group = "remote" },
			{ "<leader>s", group = "search" },
			{ "<leader>u", group = "ui" },
			{ "<leader>w", group = "windows" },
			{ "<leader>x", group = "diagnostics/quickfix" },
			{ "<leader>z", desc = "Toggle Zen Mode" },
			{ "<leader>Z", desc = "Toggle Zoom" },
			{ "[", group = "prev" },
			{ "]", group = "next" },
			{ "g", group = "goto" },
			{ "gc", desc = "which_key_ignore" }, -- built-in comment operator; not a group
		})
	end,
}
