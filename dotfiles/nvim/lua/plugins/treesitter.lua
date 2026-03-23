return {
	"nvim-treesitter/nvim-treesitter",
	cond = vim.g.vscode == nil,
	dependencies = {
		{
			"nvim-treesitter/nvim-treesitter-context",
			event = "BufReadPre",
			opts = {
				max_lines = 4,
			},
		},
		{
			"nvim-treesitter/nvim-treesitter-textobjects",
			event = "BufReadPre",
		},
	},
	event = { "BufReadPost", "BufNewFile" },
	cmd = { "TSUpdate", "TSUpdateSync" },
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			-- Neovim config
			"c",
			"lua",
			"vim",
			"vimdoc",
			"query",
			-- Web
			"javascript",
			"typescript",
			"tsx",
			"css",
			"html",
			"json",
			"jsonc",
			-- Languages
			"python",
			"rust",
			"bash",
			-- Data / config
			"yaml",
			"toml",
			"nix",
			-- Markup
			"markdown",
			"markdown_inline",
			-- Git
			"git_config",
			"git_rebase",
			"gitcommit",
			"gitignore",
		},
		sync_install = false,
		auto_install = false,
		textobjects = {
			select = {
				enable = true,
				lookahead = true,
				keymaps = {
					["af"] = { query = "@function.outer", desc = "Select outer function" },
					["if"] = { query = "@function.inner", desc = "Select inner function" },
					["ac"] = { query = "@class.outer", desc = "Select outer class" },
					["ic"] = { query = "@class.inner", desc = "Select inner class" },
					["aa"] = { query = "@parameter.outer", desc = "Select outer argument" },
					["ia"] = { query = "@parameter.inner", desc = "Select inner argument" },
					["ab"] = { query = "@block.outer", desc = "Select outer block" },
					["ib"] = { query = "@block.inner", desc = "Select inner block" },
				},
			},
			move = {
				enable = true,
				set_jumps = true,
				goto_next_start = {
					["]f"] = { query = "@function.outer", desc = "Next function start" },
					["]c"] = { query = "@class.outer", desc = "Next class start" },
					["]a"] = { query = "@parameter.inner", desc = "Next argument start" },
				},
				goto_next_end = {
					["]F"] = { query = "@function.outer", desc = "Next function end" },
					["]C"] = { query = "@class.outer", desc = "Next class end" },
				},
				goto_previous_start = {
					["[f"] = { query = "@function.outer", desc = "Prev function start" },
					["[c"] = { query = "@class.outer", desc = "Prev class start" },
					["[a"] = { query = "@parameter.inner", desc = "Prev argument start" },
				},
				goto_previous_end = {
					["[F"] = { query = "@function.outer", desc = "Prev function end" },
					["[C"] = { query = "@class.outer", desc = "Prev class end" },
				},
			},
			swap = {
				enable = true,
				swap_next = {
					["<leader>cn"] = { query = "@parameter.inner", desc = "Swap argument with next" },
				},
				swap_previous = {
					["<leader>cN"] = { query = "@parameter.inner", desc = "Swap argument with prev" },
				},
			},
		},
	},
	config = function(_, opts)
		require("nvim-treesitter.config").setup(opts)
	end,
}
