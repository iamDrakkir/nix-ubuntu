return {
	"lewis6991/gitsigns.nvim",
	cond = vim.g.vscode == nil,
	event = "BufReadPre",
	keys = {
		{ "]h", "<cmd>Gitsigns next_hunk<cr>", desc = "Next Hunk" },
		{ "[h", "<cmd>Gitsigns prev_hunk<cr>", desc = "Prev Hunk" },
		{ "<leader>ghs", "<cmd>Gitsigns stage_hunk<cr>", mode = { "n", "v" }, desc = "Stage Hunk" },
		{ "<leader>ghr", "<cmd>Gitsigns reset_hunk<cr>", mode = { "n", "v" }, desc = "Reset Hunk" },
		{ "<leader>ghS", "<cmd>Gitsigns stage_buffer<cr>", desc = "Stage Buffer" },
		{ "<leader>ghu", "<cmd>Gitsigns undo_stage_hunk<cr>", desc = "Undo Stage Hunk" },
		{ "<leader>ghR", "<cmd>Gitsigns reset_buffer<cr>", desc = "Reset Buffer" },
		{ "<leader>ghp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview Hunk" },
		{ "<leader>ghd", "<cmd>Gitsigns diffthis<cr>", desc = "Diff This" },
	},
	opts = {
		signs = {
			add = { text = "▎" },
			change = { text = "▎" },
			delete = { text = "" },
			topdelete = { text = "" },
			changedelete = { text = "▎" },
			untracked = { text = "┆" },
		},
		current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
	},
}
