return {
	"nvim-lualine/lualine.nvim",
	cond = vim.g.vscode == nil,
	event = "VeryLazy",
	config = function()
		local lualine = require("lualine")

		-- Copilot status component
		local copilot_status = (function()
			local status = "unknown" -- enabled | disabled | warning | unknown
			local icons = {
				enabled = "",
				disabled = "",
				warning = "",
				unknown = "",
			}

			local function check_status()
				local clients = vim.lsp.get_clients({ name = "copilot" })
				if #clients == 0 then
					status = "unknown"
					return
				end
				clients[1]:request("checkStatus", { localChecksOnly = true }, function(err, result)
					if err then
						status = "warning"
						return
					end
					local s = result and result.status
					if s == "OK" or s == "MaybeOK" then
						status = "enabled"
					elseif s == "NotAuthorized" then
						status = "warning"
					else
						-- NotSignedIn or anything unexpected
						status = "disabled"
					end
				end)
			end

			local copilot_augroup = vim.api.nvim_create_augroup("LualineCopilotStatus", { clear = true })
			vim.api.nvim_create_autocmd("LspAttach", {
				group = copilot_augroup,
				callback = function(ev)
					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					if client and client.name == "copilot" then
						check_status()
					end
				end,
			})
			vim.api.nvim_create_autocmd("LspDetach", {
				group = copilot_augroup,
				callback = function(ev)
					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					if client and client.name == "copilot" then
						status = "unknown"
					end
				end,
			})

			return function()
				return icons[status] or icons.unknown
			end
		end)()

		-- Cache LSP client names per buffer, updated on LspAttach/LspDetach/BufDelete
		local lsp_cache = {} -- [bufnr] -> string
		local lsp_cache_augroup = vim.api.nvim_create_augroup("LualineLspCache", { clear = true })
		vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach" }, {
			group = lsp_cache_augroup,
			callback = function(ev)
				local bufnr = ev.buf
				local clients = vim.lsp.get_clients({ bufnr = bufnr })
				local c = {}
				for _, client in pairs(clients) do
					if client.name ~= "copilot" then
						table.insert(c, client.name)
					end
				end
				lsp_cache[bufnr] = #c > 0 and (" " .. table.concat(c, " - ")) or ""
			end,
		})
		vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
			group = lsp_cache_augroup,
			callback = function(ev)
				lsp_cache[ev.buf] = nil
			end,
		})

		local function lsp_provider()
			return lsp_cache[vim.api.nvim_get_current_buf()] or ""
		end

		local function formatter()
			local status_ok, conform = pcall(require, "conform")
			if not status_ok then
				return ""
			end
			local formatters = conform.list_formatters_for_buffer(0)
			if #formatters == 0 then
				return ""
			end
			-- Deduplicate by base name (e.g. ruff_fix, ruff_format -> ruff)
			local seen = {}
			local names = {}
			for _, f in ipairs(formatters) do
				local base = type(f) == "string" and f or f.name or ""
				base = base:match("^([^_]+)") or base
				if not seen[base] then
					seen[base] = true
					names[#names + 1] = base
				end
			end
			if #names == 0 then
				return ""
			end
			return "  " .. table.concat(names, " - ")
		end

		local function diff_source()
			local gitsigns = vim.b.gitsigns_status_dict
			if gitsigns then
				return {
					added = gitsigns.added,
					modified = gitsigns.changed,
					removed = gitsigns.removed,
				}
			end
		end

		local diff = {
			"diff",
			symbols = { added = " ", modified = " ", removed = " " },
			source = diff_source,
			on_click = function()
				Snacks.picker.git_status()
			end,
		}

		local mode = {
			"mode",
			fmt = function(str)
				return str:sub(1, 3)
			end,
		}

		local branch = {
			"branch",
			icon = "",
			on_click = function()
				Snacks.picker.git_branches()
			end,
		}

		local location = {
			"location",
			padding = 0,
		}

		local function show_macro_recording()
			local recording_register = vim.fn.reg_recording()
			if recording_register == "" then
				return ""
			end
			return "Recording @" .. recording_register
		end

		local lazy = {
			require("lazy.status").updates,
			cond = require("lazy.status").has_updates,
		}

		local dashboard_extension = {
			sections = {
				lualine_a = {
					function()
						return "Dashboard"
					end,
				},
				lualine_b = { branch },
			},
			filetypes = { "snacks_dashboard" },
		}

		lualine.setup({
			options = {
				theme = "auto",
				component_separators = { left = "/", right = "/" },
				section_separators = { left = "", right = "" },
				globalstatus = true,
			},
			sections = {
				lualine_a = { mode, lazy },
				lualine_b = { branch },
				lualine_c = { diff, show_macro_recording },
				lualine_x = {
					{
						"diagnostics",
						on_click = function()
							Snacks.picker.diagnostics()
						end,
					},
				},
				lualine_y = { "filetype", formatter, lsp_provider, copilot_status, "encoding" },
				lualine_z = { location, "progress" },
			},
			inactive_sections = {},
			-- tabline = {
			--   lualine_a = { "filename" },
			--   lualine_b = {},
			--   lualine_c = {},
			--   lualine_x = {},
			--   lualine_y = {},
			--   lualine_z = { "tabs" },
			-- },
			-- winbar = {},
			extensions = { "lazy", "quickfix", "mason", dashboard_extension },
		})
	end,
}
