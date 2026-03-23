return {
	"mason-org/mason-lspconfig.nvim",
	cond = vim.g.vscode == nil,
	event = "VimEnter",
	opts = {}, -- automatic_enable = true is the default
	dependencies = {
		{
			"mason-org/mason.nvim",
			opts = {
				ui = {
					border = "rounded",
				},
			},
		},
		{ "neovim/nvim-lspconfig" },
		{ "j-hui/fidget.nvim", opts = {} },
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			opts = {
				ensure_installed = {
					-- LSP servers
					"ansiblels",
					"azure_pipelines_ls",
					"bashls",
					"jsonls",
					"lua_ls",
					"rust_analyzer",
					-- "yamlls",
					"bicep",
					"basedpyright",
					-- Formatters / linters (used by conform.nvim)
					"ruff",
					"biome",
					"copilot-language-server",
					"shfmt",
					"stylua",
				},
				auto_update = false,
				run_on_start = true,
			},
		},
	},
	cmd = { "LspInfo", "LspInstall", "LspUninstall" },
	keys = {
		{ "<leader>cl", "<cmd>LspInfo<cr>", desc = "LspInfo open" },
		{ "<leader>cm", "<cmd>Mason<cr>", desc = "Mason open" },
	},
	-- opts is passed to mason-lspconfig.setup() automatically by lazy.nvim
}
