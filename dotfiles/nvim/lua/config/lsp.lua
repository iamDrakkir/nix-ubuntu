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

-- Auto sign-in to Copilot if not authenticated
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("CopilotAutoSignIn", { clear = true }),
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if not client or client.name ~= "copilot" then
			return
		end
		local bufnr = event.buf
		client:request("checkStatus", { localChecksOnly = false }, function(err, result)
			if err or (result and result.status == "OK") then
				return
			end
			-- Not signed in — trigger the device flow sign-in
			client:request("signIn", vim.empty_dict(), function(sign_err, sign_result)
				if sign_err then
					vim.notify("Copilot sign-in error: " .. sign_err.message, vim.log.levels.ERROR)
					return
				end
				if sign_result.status == "AlreadySignedIn" then
					vim.notify("Copilot: already signed in as " .. sign_result.user)
					return
				end
				if sign_result.status == "PromptUserDeviceFlow" then
					local code = sign_result.userCode
					vim.fn.setreg("+", code)
					vim.fn.setreg("*", code)
					local choice = vim.fn.confirm(
						"Copilot: copied one-time code " .. code .. " to clipboard.\nOpen browser to complete sign-in?",
						"&Yes\n&No"
					)
					if choice == 1 and sign_result.command then
						client:exec_cmd(sign_result.command, { bufnr = bufnr }, function(cmd_err, cmd_result)
							if cmd_err then
								vim.notify("Copilot sign-in error: " .. cmd_err.message, vim.log.levels.ERROR)
								return
							end
							if cmd_result and cmd_result.status == "OK" then
								vim.notify("Copilot: signed in as " .. cmd_result.user)
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

		map("gd", vim.lsp.buf.definition, "Go to definition")
		map("gD", vim.lsp.buf.declaration, "Go to declaration")
		map("gr", vim.lsp.buf.references, "Go to references")
		map("gI", vim.lsp.buf.implementation, "Go to implementation")
		map("K", vim.lsp.buf.hover, "Hover documentation")
		map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
		map("<leader>ca", vim.lsp.buf.code_action, "Code action")
		map("<leader>ct", vim.lsp.buf.type_definition, "Type definition")
		map("<leader>cs", vim.lsp.buf.document_symbol, "Document symbols")
		map("<leader>cS", vim.lsp.buf.workspace_symbol, "Workspace symbols")

		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client:supports_method("textDocument/inlayHint") then
			vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
		end
	end,
})
