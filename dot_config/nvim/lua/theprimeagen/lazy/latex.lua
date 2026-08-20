return {
    "lervag/vimtex",
    lazy = false,
    init = function()
        vim.env.PATH = vim.fn.stdpath("config") .. "/bin:" .. vim.env.PATH
        vim.g.tex_flavor = "latex"
        vim.g.vimtex_quickfix_mode = 0
        vim.g.vimtex_view_automatic = 0
        if vim.fn.executable("latexmk") == 1 then
            vim.g.vimtex_compiler_method = "latexmk"
            vim.g.vimtex_compiler_latexmk = {
                build_dir = "",
                callback = 1,
                continuous = 1,
                executable = "latexmk",
                hooks = {},
                options = {
                    "-pdf",
                    "-verbose",
                    "-auxdir=.latexbuild",
                    "-file-line-error",
                    "-synctex=0",
                    "-interaction=nonstopmode",
                },
            }
        else
            vim.g.vimtex_compiler_method = "generic"
            vim.g.vimtex_compiler_generic = {
                command = "pdflatex -file-line-error -synctex=1 -interaction=nonstopmode %f",
            }
        end

        if vim.fn.executable("mupdf") == 1 then
            vim.g.vimtex_view_method = "mupdf"
        elseif vim.fn.executable("sioyek") == 1 then
            vim.g.vimtex_view_method = "sioyek"
        elseif vim.fn.executable("skim") == 1 then
            vim.g.vimtex_view_method = "skim"
        elseif vim.fn.executable("zathura") == 1 then
            vim.g.vimtex_view_method = "zathura"
        elseif vim.fn.executable("open") == 1 then
            vim.g.vimtex_view_method = "general"
            vim.g.vimtex_view_general_viewer = "open"
            vim.g.vimtex_view_general_options = "@pdf"
        end
    end,
    config = function()
        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "tex", "plaintex", "bib" },
            callback = function()
                vim.opt_local.spell = true
                vim.opt_local.wrap = true
                vim.opt_local.linebreak = true
                vim.opt_local.textwidth = 80
                vim.opt_local.conceallevel = 2

                local opts = { buffer = true, silent = true }
                vim.keymap.set("n", "<leader>ll", "<cmd>VimtexCompile<CR>", opts)
                vim.keymap.set("n", "<leader>lv", "<cmd>VimtexView<CR>", opts)
                vim.keymap.set("n", "<leader>lc", "<cmd>VimtexClean<CR>", opts)
                vim.keymap.set("n", "<leader>le", "<cmd>VimtexErrors<CR>", opts)
                vim.keymap.set("n", "<leader>lt", "<cmd>VimtexTocToggle<CR>", opts)
                vim.keymap.set("n", "<leader>ls", "<cmd>VimtexStatus<CR>", opts)
            end,
        })
    end,
}
