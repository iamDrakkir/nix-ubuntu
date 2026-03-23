vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- UI
opt.termguicolors = true  -- True color support
opt.number = true         -- Show line numbers
opt.relativenumber = true -- Use relative line number
opt.scrolloff = 8         -- Lines of context
opt.showmode = false      -- Dont show mode in cmd line, It is in statusline
opt.cursorline = true     -- Highligting the current line
opt.signcolumn = "yes"    -- Always show the signcolumn, otherwise it would shift the text each time
opt.conceallevel = 1      -- conceral text
opt.wrap = false          -- No line wrap
opt.splitbelow = true     -- Put new windows below current
opt.splitright = true     -- Put new windows right of current
opt.splitkeep = "screen"  -- Keep text on screen when splitting
opt.list = true           -- Show invisible charachters (tabs, space...)
opt.laststatus = 3
opt.pumheight = 10        -- Maximum number of entries in a popup menu

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
opt.hlsearch = true            -- Highlight all matches from search pattern
opt.ignorecase = true          -- Ignore case in search pattern
opt.smartcase = true           -- Don't ignore case in seaches if capitalization is used
opt.iskeyword:append("-")      -- Treat words with - as one word
opt.grepformat = "%f:%l:%c:%m" -- fileneme:line:column:error
opt.grepprg = "rg --vimgrep"   -- use rg for grep

-- Tabs and spaces
opt.expandtab = true   -- Use spaces instead of tabs
opt.smartindent = true -- Insert indentation automatically
opt.shiftround = true  -- Round indent to multiple of 'shiftwidth'.
opt.tabstop = 4        -- Number of spaces tabs count for
opt.shiftwidth = 4     -- Size of indents
opt.softtabstop = 4    -- Number of spaces for <Tab> in insert mode

-- System
opt.autowrite = true                      -- Enable auto write
opt.clipboard = "unnamedplus"             -- Sync with system clipboard
opt.swapfile = false
opt.undofile = true                       -- Persistant undo
opt.undolevels = 10000                    -- Large undo history
opt.updatetime = 200                      -- Faster completion
opt.diffopt:append({
  "algorithm:patience",
  "linematch:60",
  "vertical",
})          -- Better diff options
opt.shortmess:append({
  W = true, -- Disable "writen" message
  I = true, -- Disable into messages
  c = true, -- Disable "match 1 of 2" and simular messages
})

-- Use uv-managed Python so Mason's pypi installer finds a Python that has pip.
-- `uv python find` resolves the current managed install regardless of version.
local uv_python = vim.trim(vim.fn.system("uv python find 2>/dev/null"))
if uv_python ~= "" and vim.fn.executable(uv_python) == 1 then
  local uv_python_bin = vim.fn.fnamemodify(uv_python, ":h")
  vim.env.PATH = uv_python_bin .. ":" .. vim.env.PATH
  vim.g.python3_host_prog = uv_python
else
  vim.g.python3_host_prog = "python3"
end
