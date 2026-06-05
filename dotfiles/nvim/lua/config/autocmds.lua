local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text
local yankGroup = augroup("HighlightYank", { clear = true })
autocmd("TextYankPost", {
	group = yankGroup,
	pattern = "*",
	desc = "Highlight yanked text",
	callback = function()
		vim.hl.on_yank({ higroup = "IncSearch", timeout = 40 })
	end,
})

-- Go to last loc when opening a buffer
local lastLocGroup = augroup("LastLoc", { clear = true })
autocmd("BufReadPost", {
	group = lastLocGroup,
	desc = "Go to last loc when opening a buffer",
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Remove trailing whitespaces for filetypes not handled by conform.nvim
-- (conform formatters already strip trailing whitespace for configured filetypes)
local removeTrailingGroup = augroup("RemoveTrailing", { clear = true })
local function trim_trailing_whitespaces()
	if not vim.o.binary and vim.o.filetype ~= "diff" then
		-- Skip if conform has a formatter for this buffer
		local ok, conform = pcall(require, "conform")
		if ok and #conform.list_formatters_for_buffer(0) > 0 then
			return
		end
		local current_view = vim.fn.winsaveview()
		vim.api.nvim_command([[keeppatterns %s/\s\+$//e]])
		vim.fn.winrestview(current_view)
	end
end
autocmd({ "BufWritePre" }, {
	group = removeTrailingGroup,
	pattern = "*",
	desc = "Remove trailing whitespaces",
	callback = trim_trailing_whitespaces,
})

-- spell correction and wrap for git commits and markdown files
local wrapSpellGroup = augroup("WrapSpell", { clear = true })
autocmd("FileType", {
	group = wrapSpellGroup,
	pattern = { "gitcommit", "markdown" },
	desc = "Wrap and check for spell in text filetypes",
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

-- Remove some formatoptions
-- NOTE: removing "q" would disable `gq` manual reflow — only strip auto-comment flags
local formatOptionsGroup = augroup("FormatOptions", { clear = true })
autocmd("FileType", {
	group = formatOptionsGroup,
	pattern = "*",
	desc = "Remove auto-comment continuation formatoptions",
	callback = function()
		vim.opt_local.formatoptions:remove({
			"c", -- No autowrap comments
			"r", -- No comment leader on 'enter'
			"o", -- No comment leader on o/O
		})
	end,
})

-- Close more filetypes with <q> and <esc>
local closeWithQGroup = augroup("CloseWithQ", { clear = true })
autocmd("FileType", {
	group = closeWithQGroup,
	pattern = {
		"qf",
		"help",
		"man",
		"startuptime",
		"lazy",
		"minifiles",
		"lazygit",
		"DiffviewFiles",
		"DiffviewFileHistory",
	},
	desc = "Close more filetypes with <q> and <esc>",
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true, desc = "Close window" })
		vim.keymap.set("n", "<esc>", "<cmd>close<cr>", { buffer = event.buf, silent = true, desc = "Close window" })
	end,
})
