vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- UI
opt.termguicolors = true -- True color support
opt.number = true -- Show line numbers
opt.relativenumber = true -- Use relative line number
opt.scrolloff = 8 -- Lines of context
opt.showmode = false -- Dont show mode in cmd line, It is in statusline
opt.cursorline = true -- Highligting the current line
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.conceallevel = 1 -- conceal text
opt.wrap = false -- No line wrap
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
opt.splitkeep = "screen" -- Keep text on screen when splitting
opt.list = true -- Show invisible charachters (tabs, space...)
opt.laststatus = 3
opt.pumheight = 10 -- Maximum number of entries in a popup menu

opt.listchars = {
	tab = ">-",
	extends = ">",
	precedes = "<",
	nbsp = "+",
	space = "⋅",
	trail = "⋅",
	-- eol = "↴",
}
opt.fillchars = { eob = " " } -- No tilde at the end of the file

-- Search
opt.hlsearch = true -- Highlight all matches from search pattern
opt.ignorecase = true -- Ignore case in search pattern
opt.smartcase = true -- Don't ignore case in searches if capitalization is used
opt.iskeyword:append("-") -- Treat words with - as one word
opt.grepformat = "%f:%l:%c:%m" -- fileneme:line:column:error
opt.grepprg = "rg --vimgrep" -- use rg for grep

-- Tabs and spaces
opt.expandtab = true -- Use spaces instead of tabs
opt.smartindent = true -- Insert indentation automatically
opt.shiftround = true -- Round indent to multiple of 'shiftwidth'.
opt.tabstop = 4 -- Number of spaces tabs count for
opt.shiftwidth = 4 -- Size of indents
opt.softtabstop = 4 -- Number of spaces for <Tab> in insert mode

-- System
opt.autowrite = true -- Enable auto write
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.swapfile = false
opt.undofile = true -- Persistant undo
opt.undolevels = 10000 -- Large undo history
opt.updatetime = 200 -- Faster completion
opt.diffopt:append({
	"algorithm:patience",
	"linematch:60",
	"vertical",
}) -- Better diff options
opt.shortmess:append({
	W = true, -- Disable "writen" message
	I = true, -- Disable intro messages
	c = true, -- Disable "match 1 of 2" and simular messages
})

-- Use uv-managed Python so Mason's pypi installer finds a Python that has pip.
-- Resolved lazily via a FileType autocmd so it doesn't block startup for non-Python sessions.
vim.g.python3_host_prog = "python3"
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python" },
	once = true,
	callback = function()
		vim.fn.jobstart({ "uv", "python", "find" }, {
			stdout_buffered = true,
			on_stdout = function(_, data)
				local path = vim.trim(table.concat(data, ""))
				if path ~= "" and vim.fn.executable(path) == 1 then
					vim.g.python3_host_prog = path
					vim.env.PATH = vim.fn.fnamemodify(path, ":h") .. ":" .. vim.env.PATH
				end
			end,
		})
	end,
})
