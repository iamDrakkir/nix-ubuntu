 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#070722',
    base01 = '#11112d',
    base02 = '#17173c',
    base03 = '#51589b',
    base04 = '#7c80b4',
    base05 = '#f3edf7',
    base06 = '#f3edf7',
    base07 = '#f3edf7',
    base08 = '#fd4663',
    base09 = '#9bfece',
    base0A = '#a9aefe',
    base0B = '#fff59b',
    base0C = '#81fec1',
    base0D = '#fff280',
    base0E = '#8188fe',
    base0F = '#8f0118',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#f3edf7',          bg = '#070722' })
  hi('TelescopeBorder',         { fg = '#51589b',             bg = '#070722' })
  hi('TelescopePromptNormal',   { fg = '#f3edf7',          bg = '#070722' })
  hi('TelescopePromptBorder',   { fg = '#51589b',             bg = '#070722' })
  hi('TelescopePromptPrefix',   { fg = '#fff59b',             bg = '#070722' })
  hi('TelescopePromptCounter',  { fg = '#7c80b4',  bg = '#070722' })
  hi('TelescopePromptTitle',    { fg = '#070722',             bg = '#fff59b' })
  hi('TelescopePreviewTitle',   { fg = '#070722',             bg = '#a9aefe' })
  hi('TelescopeResultsTitle',   { fg = '#070722',             bg = '#9bfece' })
  hi('TelescopeSelection',      { fg = '#f3edf7',          bg = '#17173c' })
  hi('TelescopeSelectionCaret', { fg = '#fff59b',             bg = '#17173c' })
  hi('TelescopeMatching',       { fg = '#fff59b',             bold = true })
end

 -- Register a signal handler for SIGUSR1 (matugen updates)
 local signal = vim.uv.new_signal()
 signal:start(
   'sigusr1',
   vim.schedule_wrap(function()
     package.loaded['matugen'] = nil
     require('matugen').setup()
   end)
 )

 return M
