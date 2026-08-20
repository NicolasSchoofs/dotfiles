return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-omni",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "texlab",
            },
            automatic_enable = {
                exclude = { "jdtls" },
            },
            handlers = {
                function(server_name) -- default handler (optional)

                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,

                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,

                ["jdtls"] = function()
                    -- Java is configured by lua/theprimeagen/lazy/jdtls.lua.
                end,

                ["ts_ls"] = function()
                    require("lspconfig").ts_ls.setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                        root_dir = require("lspconfig").util.root_pattern(
                            "tsconfig.json", "package.json", "jsconfig.json"
                        ),
                        single_file_support = false,
                    })
                end,

                ["texlab"] = function()
                    require("lspconfig").texlab.setup({
                        capabilities = capabilities,
                        settings = {
                            texlab = {
                                build = {
                                    executable = "latexmk",
                                    args = {
                                        "-pdf",
                                        "-interaction=nonstopmode",
                                        "-synctex=1",
                                        "%f",
                                    },
                                    onSave = false,
                                    forwardSearchAfter = false,
                                },
                                chktex = {
                                    onEdit = false,
                                    onOpenAndSave = false,
                                },
                            },
                        },
                    })
                end,
            }
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, {
                { name = 'buffer' },
                })
        })

        cmp.setup.filetype({ "tex", "plaintex", "bib" }, {
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "omni" },
            }, {
                { name = "buffer" },
                { name = "path" },
            }),
        })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "c", "cpp", "typescript", "typescriptreact" },
            callback = function()
                vim.keymap.set("n", "=", function()
                    vim.lsp.buf.format()
                end, { buffer = true })

                vim.keymap.set("v", "=", function()
                    local start = vim.api.nvim_buf_get_mark(0, "<")
                    local finish = vim.api.nvim_buf_get_mark(0, ">")
                    vim.lsp.buf.format({
                        range = {
                            ["start"] = { start[1], start[2] },
                            ["end"] = { finish[1], finish[2] },
                        }
                    })
                    vim.api.nvim_feedkeys(
                        vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
                        "n", false
                    )
                end, { buffer = true })
            end,
        })
        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
