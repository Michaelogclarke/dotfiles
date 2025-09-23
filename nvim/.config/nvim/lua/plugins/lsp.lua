-- lua/plugins/lsp.lua
return {
    "neovim/nvim-lspconfig",
    dependencies = {
        -- LSP installer/bridge
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        -- Autocompletion
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lua",
        -- Snippets
        "L3MON4D3/LuaSnip",
        "rafamadriz/friendly-snippets",
        -- (optional nice-to-haves)
        -- "windwp/nvim-ts-autotag",
        -- "hrsh7th/cmp-nvim-lsp-signature-help",
    },
    config = function()
        ---------------------------------------------------------------------------
        -- Safe requires (avoid hard crashes if a dep is missing temporarily)
        ---------------------------------------------------------------------------
        local ok_cmp, cmp = pcall(require, "cmp")
        local ok_lspconfig, lspconfig = pcall(require, "lspconfig")
        local ok_mason, mason = pcall(require, "mason")
        local ok_mlsp, mason_lspconfig = pcall(require, "mason-lspconfig")
        local ok_luasnip, luasnip = pcall(require, "luasnip")

        if not (ok_cmp and ok_lspconfig and ok_mason and ok_mlsp and ok_luasnip) then
            vim.defer_fn(function()
                vim.notify("LSP setup: some deps not ready yet. Run :Lazy and restart.", vim.log.levels.WARN)
            end, 10)
            return
        end

        ---------------------------------------------------------------------------
        -- Autoformat filetypes (your original)
        ---------------------------------------------------------------------------
        local autoformat_filetypes = { "lua" }
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if not client then return end
                if vim.tbl_contains(autoformat_filetypes, vim.bo[args.buf].filetype) then
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        buffer = args.buf,
                        callback = function()
                            vim.lsp.buf.format({
                                formatting_options = { tabSize = 4, insertSpaces = true },
                                bufnr = args.buf,
                                id = client.id,
                            })
                        end,
                    })
                end
            end,
        })

        ---------------------------------------------------------------------------
        -- UI tweaks
        ---------------------------------------------------------------------------
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help,
            { border = "rounded" })
        vim.diagnostic.config({
            virtual_text = true,
            severity_sort = true,
            float = { style = "minimal", border = "rounded", header = "", prefix = "" },
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = "✘",
                    [vim.diagnostic.severity.WARN]  = "▲",
                    [vim.diagnostic.severity.HINT]  = "⚑",
                    [vim.diagnostic.severity.INFO]  = "»",
                },
            },
        })

        ---------------------------------------------------------------------------
        -- nvim-cmp + snippets
        ---------------------------------------------------------------------------
        require("luasnip.loaders.from_vscode").lazy_load()
        vim.opt.completeopt = { "menu", "menuone", "noselect" }

        cmp.setup({
            preselect = "item",
            completion = { completeopt = "menu,menuone,noinsert" },
            window = { documentation = cmp.config.window.bordered() },
            sources = {
                { name = "path" },
                { name = "nvim_lsp" },
                { name = "buffer",  keyword_length = 3 },
                { name = "luasnip", keyword_length = 2 },
                -- { name = "nvim_lsp_signature_help" }, -- optional
            },
            snippet = {
                expand = function(args) luasnip.lsp_expand(args.body) end,
            },
            formatting = {
                fields = { "abbr", "menu", "kind" },
                format = function(entry, item)
                    item.menu = entry.source.name == "nvim_lsp" and "[LSP]" or ("[" .. entry.source.name .. "]")
                    return item
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<CR>"]    = cmp.mapping.confirm({ select = false }),
                ["<C-f>"]   = cmp.mapping.scroll_docs(5),
                ["<C-u>"]   = cmp.mapping.scroll_docs(-5),
                ["<C-e>"]   = cmp.mapping(function()
                    if cmp.visible() then cmp.abort() else cmp.complete() end
                end),
                ["<Tab>"]   = cmp.mapping(function(fallback)
                    local col = vim.fn.col(".") - 1
                    if cmp.visible() then
                        cmp.select_next_item({ behavior = "select" })
                    elseif col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
                        fallback()
                    else
                        cmp.complete()
                    end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = "select" }),
                ["<C-d>"]   = cmp.mapping(function(fallback)
                    if luasnip.jumpable(1) then luasnip.jump(1) else fallback() end
                end, { "i", "s" }),
                ["<C-b>"]   = cmp.mapping(function(fallback)
                    if luasnip.jumpable(-1) then luasnip.jump(-1) else fallback() end
                end, { "i", "s" }),
            }),
        })

        ---------------------------------------------------------------------------
        -- LSP: capabilities + keymaps
        ---------------------------------------------------------------------------
        local lsp_defaults = require("lspconfig").util.default_config
        lsp_defaults.capabilities = vim.tbl_deep_extend(
            "force",
            lsp_defaults.capabilities,
            require("cmp_nvim_lsp").default_capabilities()
        )

        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(event)
                local opts = { buffer = event.buf }
                vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
                vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
                vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
                vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
                vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
                vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
                vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
                vim.keymap.set("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>", opts)
                vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
                vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
                vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
            end,
        })

        ---------------------------------------------------------------------------
        -- Mason + Mason-LSPConfig
        ---------------------------------------------------------------------------
        mason.setup({})
        mason_lspconfig.setup({
            ensure_installed = {
                "lua_ls",
                -- Web
                "html",
                "cssls",
                "jsonls",
                "emmet_ls",
                "tailwindcss",
                -- JS/TS
                "ts_ls", -- (renamed from tsserver)
                "eslint",
                -- Vue (you prefer Vue)
                "volar",
            },
            handlers = {
                function(server_name) lspconfig[server_name].setup({}) end,

                lua_ls = function()
                    lspconfig.lua_ls.setup({
                        settings = {
                            Lua = {
                                runtime = { version = "LuaJIT" },
                                diagnostics = { globals = { "vim" } },
                                workspace = { library = { vim.env.VIMRUNTIME } },
                            },
                        },
                    })
                end,

                html = function()
                    lspconfig.html.setup({
                        filetypes = { "html", "htmldjango", "templ", "twig", "hbs" },
                    })
                end,

                cssls = function()
                    lspconfig.cssls.setup({
                        settings = {
                            css  = { validate = true },
                            less = { validate = true },
                            scss = { validate = true },
                        },
                    })
                end,

                jsonls = function()
                    lspconfig.jsonls.setup({
                        settings = {
                            json = { validate = { enable = true } },
                        },
                    })
                end,

                emmet_ls = function()
                    lspconfig.emmet_ls.setup({
                        filetypes = {
                            "html", "css", "scss", "less",
                            "javascriptreact", "typescriptreact",
                            "vue", "svelte", "astro",
                            "heex", "eelixir", "elixir", "templ",
                        },
                        init_options = { html = { options = { ["bem.enabled"] = true } } },
                    })
                end,

                tailwindcss = function()
                    lspconfig.tailwindcss.setup({
                        filetypes = {
                            "html", "css", "scss", "less",
                            "javascript", "javascriptreact", "typescript", "typescriptreact",
                            "vue", "svelte", "astro",
                        },
                        root_dir = require("lspconfig.util").root_pattern(
                            "tailwind.config.js", "tailwind.config.cjs", "tailwind.config.ts",
                            "postcss.config.js", "package.json", ".git"
                        ),
                    })
                end,

                ts_ls = function()
                    lspconfig.ts_ls.setup({
                        -- Example: disable formatting if you plan to use Prettier via conform.nvim
                        -- on_attach = function(client) client.server_capabilities.documentFormattingProvider = false end,
                    })
                end,

                eslint = function()
                    lspconfig.eslint.setup({
                        -- Optional: auto-fix on save
                        -- on_attach = function(_, bufnr)
                        --   vim.api.nvim_create_autocmd("BufWritePre", { buffer = bufnr, command = "EslintFixAll" })
                        -- end
                    })
                end,

                volar = function()
                    lspconfig.volar.setup({
                        filetypes = { "vue" },
                        init_options = { vue = { hybridMode = true } },
                    })
                end,
            },
        })
    end,
}
