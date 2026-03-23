return {
    "folke/lazydev.nvim",
    ft = "lua",
    cond = vim.g.vscode == nil,
    opts = {
        library = {
            { path = "${3rd}/luv/library",                    words = { "vim%.uv" } },
            { path = vim.fn.stdpath("data") .. "/lazy/snacks.nvim",   words = { "Snacks" } },
            { path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim",     words = { "Lazy" } },
        },
    },
}
