return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    cond = vim.g.vscode == nil,
    opts = {
        notify_on_error = false,
        format_on_save = {
            timeout_ms = 500,
            lsp_format = "fallback",
        },
        formatters_by_ft = {
            lua = { "stylua" },
            python = {
                -- To fix auto-fixable lint errors.
                "ruff_fix",
                -- To run the Ruff formatter.
                "ruff_format",
                -- To organize the imports.
                "ruff_organize_imports",
            },
            -- Biome handles JS/TS ecosystem
            javascript = { "biome" },
            javascriptreact = { "biome" },
            typescript = { "biome" },
            typescriptreact = { "biome" },
            json = { "biome" },
            jsonc = { "biome" },
            css = { "biome" },
            -- Shell
            sh = { "shfmt" },
            bash = { "shfmt" },
            -- Nix
            nix = { "nixfmt" },
        },
    },
}
