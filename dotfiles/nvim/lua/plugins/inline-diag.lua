return {
	"rachartier/tiny-inline-diagnostic.nvim",
	cond = vim.g.vscode == nil,
	event = "LspAttach",
	priority = 900,
	opts = {
		options = {
			multilines = {
				enable = true,
			},
		},
	},
}
