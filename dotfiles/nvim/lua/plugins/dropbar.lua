return {
	"Bekaboo/dropbar.nvim",
	event = { "BufReadPost", "BufNewFile" },
	cond = vim.g.vscode == nil,
	config = true,
}
