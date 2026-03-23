return {
	"mason-org/mason-lspconfig.nvim",
	cond = vim.g.vscode == nil,
	event = { "BufReadPre", "BufNewFile" },
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
		{ "b0o/schemastore.nvim" },
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
					"nixfmt",
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
	config = function(_, opts)
		-- Wire jsonls to schemastore now that the dependency is loaded
		vim.lsp.config("jsonls", {
			settings = {
				json = {
					schemas = require("schemastore").json.schemas(),
					validate = { enable = true },
				},
			},
		})
		require("mason-lspconfig").setup(opts)
	end,
}
