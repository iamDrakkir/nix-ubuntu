return {
    "folke/snacks.nvim",
    priority = 1000,
    cond = vim.g.vscode == nil,
    lazy = false,
    keys = {
        -- picker
        { "<leader>ff", function() Snacks.picker.files() end,                            desc = "Find Files" },
        { "<leader>fb", function() Snacks.picker.buffers() end,                          desc = "Switch Buffer" },
        { "<leader>fo", function() Snacks.picker.recent() end,                           desc = "Old Files" },
        { "<leader>fg", function() Snacks.picker.git_files() end,                        desc = "Find Git Files" },
        { "<leader>sg", function() Snacks.picker.grep() end,                             desc = "Grep (root dir)" },
        { "<leader>sw", function() Snacks.picker.grep_word() end,                        desc = "Word (root dir)", mode = { "n", "x" } },
        { "<leader>sb", function() Snacks.picker.lines() end,                            desc = "Buffer Lines" },
        { "<leader>sd", function() Snacks.picker.diagnostics() end,                      desc = "Diagnostics" },
        { "<leader>sh", function() Snacks.picker.help() end,                             desc = "Help Pages" },
        { "<leader>sk", function() Snacks.picker.keymaps() end,                          desc = "Key Maps" },
        { "<leader>sM", function() Snacks.picker.man() end,                              desc = "Man Pages" },
        { "<leader>sm", function() Snacks.picker.marks() end,                            desc = "Jump to Mark" },
        { "<leader>so", function() Snacks.picker.vim_options() end,                      desc = "Options" },
        { "<leader>sC", function() Snacks.picker.commands() end,                         desc = "Commands" },
        { "<leader>sc", function() Snacks.picker.command_history() end,                  desc = "Command History" },
        { "<leader>s:", function() Snacks.picker.command_history() end,                  desc = "Command History" },
        { "<leader>sa", function() Snacks.picker.autocmds() end,                         desc = "Auto Commands" },
        { "<leader>sH", function() Snacks.picker.highlights() end,                       desc = "Search Highlight Groups" },
        { "<leader>uC", function() Snacks.picker.colorschemes() end,                     desc = "Colorscheme with preview" },
        { "<leader>fu", function() Snacks.picker.undo() end,                             desc = "Undo Tree" },
        { "<leader>p",  function() Snacks.picker.cliphist() end,                         desc = "Clipboard History" },
        -- git
        { "<leader>gc", function() Snacks.picker.git_log() end,                          desc = "Git Commits" },
        { "<leader>gs", function() Snacks.picker.git_status() end,                       desc = "Git Status" },
        { "<leader>gb", function() Snacks.git.blame_line() end,                          desc = "Git Blame Line" },
        -- zen / misc (existing)
        { "<leader>z",  function() Snacks.zen() end,                                     desc = "Toggle Zen Mode" },
        { "<leader>Z",  function() Snacks.zen.zoom() end,                                desc = "Toggle Zoom" },
        { "<leader>n",  function() Snacks.notifier.show_history() end,                   desc = "Notification History" },
        { "<leader>cR", function() Snacks.rename.rename_file() end,                      desc = "Rename File" },
        { "<leader>gB", function() Snacks.gitbrowse() end,                               desc = "Git Browse" },
        { "<leader>gf", function() Snacks.lazygit.log_file() end,                        desc = "Lazygit Current File History" },
        { "<leader>gg", function() Snacks.lazygit() end,                                 desc = "Lazygit" },
        { "<leader>gl", function() Snacks.lazygit.log() end,                             desc = "Lazygit Log (cwd)" },
        { "<leader>un", function() Snacks.notifier.hide() end,                           desc = "Dismiss All Notifications" },
        { "<c-/>",      function() Snacks.terminal() end,                                desc = "Toggle Terminal" },
        { "<c-_>",      function() Snacks.terminal() end,                                desc = "which_key_ignore" },
        { "]]",         function() Snacks.words.jump(vim.v.count1) end,                  desc = "Next Reference",              mode = { "n", "t" } },
        { "[[",         function() Snacks.words.jump(-vim.v.count1) end,                 desc = "Prev Reference",              mode = { "n", "t" } },
        { "<leader>si", function() Snacks.image.hover() end,                             desc = "Image hover" },
    },
    opts = {
        animate = { enabled = true },
        bigfile = { enabled = true },
        bufdelete = { enabled = true },
        dashboard = { enabled = true },
        debug = { enabled = false },
        dim = { enabled = true },
        explorer = { enabled = false },
        git = { enabled = true },
        gitbrowse = { enabled = true },
        image = {
            enabled = true,
            -- Ghostty supports the Kitty Graphics Protocol natively.
            -- Force detection in case TERM_PROGRAM env var isn't set inside nvim.
            env = { GHOSTTY = true },
            doc = {
                enabled = true,
                inline = true,  -- render images inline in markdown/html/etc.
                float = true,
            },
        },
        indent = { enabled = true },
        input = { enabled = true },
        layout = { enabled = false },
        lazygit = { enabled = true },
        notifier = {
            enabled = true,
            filter = function(notif)
                -- Suppress common noisy write messages
                if notif.msg and (
                    notif.msg:find(" written") or
                    notif.msg:find("%d+L, %d+B") or
                    notif.msg:find("No information available")
                ) then
                    return false
                end
                return true
            end,
        },
        notify = { enabled = true },
        picker = {
            enabled = true,
            sources = {
                files = {
                    hidden = true,
                    ignored = false,
                    exclude = { ".git", ".venv" },
                },
            },
        },
        profiler = { enabled = false },
        quickfile = { enabled = true },
        rename = { enabled = true },
        scope = { enabled = true },
        scratch = { enabled = true },
        scroll = { enabled = true },
        statuscolumn = { enabled = true },
        terminal = { enabled = true },
        toggle = { enabled = true },
        util = { enabled = true },
        win = { enabled = true },
        words = { enabled = true },
        zen = { enabled = true },
    },
}
