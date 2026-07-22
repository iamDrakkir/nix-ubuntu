return {
	"amitds1997/remote-nvim.nvim",
	cond = vim.g.vscode == nil,
	version = "*", -- Pin to GitHub releases
	dependencies = {
		"nvim-lua/plenary.nvim", -- For standard functions
		"MunifTanjim/nui.nvim", -- To build the plugin UI
		"nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
	},
	cmd = { "RemoteStart", "RemoteStop", "RemoteInfo", "RemoteCleanup", "RemoteConfigDel", "RemoteLog" },
	keys = {
		{ "<leader>rs", "<cmd>RemoteStart<cr>", desc = "Remote Start/Connect" },
		{ "<leader>rS", "<cmd>RemoteStop<cr>", desc = "Remote Stop" },
		{ "<leader>ri", "<cmd>RemoteInfo<cr>", desc = "Remote Info" },
		{ "<leader>rc", "<cmd>RemoteCleanup<cr>", desc = "Remote Cleanup" },
		{ "<leader>rl", "<cmd>RemoteLog<cr>", desc = "Remote Log" },
	},
	-- See the README for the full option list:
	-- https://github.com/amitds1997/remote-nvim.nvim#advanced-configuration
	-- Devcontainer mode requires `devpod` (>= 0.5.0); this system uses rootless
	-- Podman instead of Docker, so point the docker-based modes at `podman`.
	-- Run `:checkhealth remote-nvim` after first loading the plugin.
	opts = {
		devpod = {
			docker_binary = "podman",
		},
	},
}
