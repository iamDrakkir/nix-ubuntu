-- Server-specific overrides
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
})

vim.lsp.config("basedpyright", {
	settings = {
		basedpyright = {
			analysis = {
				autoSearchPaths = true,
				diagnosticMode = "workspace",
				useLibraryCodeForTypes = true,
				typeCheckingMode = "strict",
			},
		},
	},
})

vim.lsp.config("copilot", {
	settings = {
		telemetry = {
			telemetryLevel = "off",
		},
	},
})

-- jsonls schema config is set in plugins/lsp.lua where schemastore is available as a dependency
-- Auto sign-in to Copilot if not authenticated
if vim.g.vscode == nil then
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("CopilotAutoSignIn", { clear = true }),
		callback = function(event)
			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if not client or client.name ~= "copilot" then
				return
			end
			local bufnr = event.buf
			-- Use localChecksOnly = true to avoid a network call on every buffer attach
			client:request("checkStatus", { localChecksOnly = true }, function(err, result)
				if err or (result and result.status == "OK") then
					return
				end
				-- Not signed in locally — trigger the device flow sign-in
				client:request("signIn", vim.empty_dict(), function(sign_err, sign_result)
					if sign_err then
						vim.notify("Copilot sign-in error: " .. sign_err.message, vim.log.levels.ERROR)
						return
					end
					if sign_result.status == "AlreadySignedIn" then
						vim.notify("Copilot: already signed in as " .. (sign_result.user or "unknown"))
						return
					end
					if sign_result.status == "PromptUserDeviceFlow" then
						local code = sign_result.userCode
						vim.fn.setreg("+", code)
						vim.fn.setreg("*", code)
						local choice = vim.fn.confirm(
							"Copilot: copied one-time code "
								.. code
								.. " to clipboard.\nOpen browser to complete sign-in?",
							"&Yes\n&No"
						)
						if choice == 1 and sign_result.command then
							client:exec_cmd(sign_result.command, { bufnr = bufnr }, function(cmd_err, cmd_result)
								if cmd_err then
									vim.notify("Copilot sign-in error: " .. cmd_err.message, vim.log.levels.ERROR)
									return
								end
								if cmd_result and cmd_result.status == "OK" then
									vim.notify("Copilot: signed in as " .. (cmd_result.user or "unknown"))
								end
							end)
						end
					end
				end)
			end)
		end,
	})

	-- Buffer-local keymaps and inlay hints on attach
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
		callback = function(event)
			local map = function(keys, func, desc)
				vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
			end

			-- Use Snacks picker for navigation (consistent with the rest of the config)
			map("gd", function()
				Snacks.picker.lsp_definitions()
			end, "Go to definition")
			map("gD", vim.lsp.buf.declaration, "Go to declaration")
			map("gr", function()
				Snacks.picker.lsp_references()
			end, "Go to references")
			map("gI", function()
				Snacks.picker.lsp_implementations()
			end, "Go to implementation")
			map("K", function()
				vim.lsp.buf.hover({ border = "rounded" })
			end, "Hover documentation")
			map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
			map("<leader>ca", vim.lsp.buf.code_action, "Code action")
			map("<leader>ct", vim.lsp.buf.type_definition, "Type definition")
			-- <leader>cy to avoid conflict with treesitter swap keymaps under <leader>cs
			map("<leader>cy", function()
				Snacks.picker.lsp_symbols()
			end, "Document symbols")
			map("<leader>cY", function()
				Snacks.picker.lsp_workspace_symbols()
			end, "Workspace symbols")

			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if client and client:supports_method("textDocument/inlayHint") then
				vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
			end
		end,
	})

	-- Built-in LSP progress (replaces fidget.nvim)
	vim.api.nvim_create_autocmd("LspProgress", {
		group = vim.api.nvim_create_augroup("LspProgressEcho", { clear = true }),
		callback = function(ev)
			local value = ev.data.params.value
			vim.api.nvim_echo({ { value.message or "done" } }, false, {
				id = "lsp." .. ev.data.client_id,
				kind = "progress",
				source = "vim.lsp",
				title = value.title,
				status = value.kind ~= "end" and "running" or "success",
				percent = value.percentage,
			})
		end,
	})

	-- Compat shims: LspInfo/LspRestart/LspLog were removed in nvim-lspconfig for 0.12
	vim.api.nvim_create_user_command("LspInfo", "checkhealth vim.lsp", {
		desc = "Show LSP info (via checkhealth)",
	})

	vim.api.nvim_create_user_command("LspRestart", "lsp restart", {
		desc = "Restart LSP servers",
	})

	vim.api.nvim_create_user_command("LspLog", function(_)
		local log_path = vim.fs.joinpath(vim.fn.stdpath("state"), "lsp.log")
		vim.cmd("edit " .. log_path)
	end, {
		desc = "Open LSP log file",
	})
end
