
return {
    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = "make install_jsregexp",

        dependencies = { "rafamadriz/friendly-snippets" },

        config = function()
            local ls = require("luasnip")
            local s = ls.snippet
            local t = ls.text_node
            local i = ls.insert_node
            require("luasnip.loaders.from_vscode").lazy_load()

            ls.filetype_extend("javascript", { "jsdoc" })
            ls.filetype_extend("plaintex", { "tex" })
            ls.filetype_extend("bib", { "bibtex" })

            ls.add_snippets("tex", {
                s("title", {
                    t("\\title{"), i(1, "Title"), t("}"),
                }),
                s("author", {
                    t("\\author{"), i(1, "Author"), t("}"),
                }),
                s("date", {
                    t("\\date{"), i(1, "\\today"), t("}"),
                }),
                s("documentclass", {
                    t("\\documentclass{"), i(1, "article"), t("}"),
                }),
                s("usepackage", {
                    t("\\usepackage{"), i(1, "package"), t("}"),
                }),
                s("maketitle", {
                    t("\\maketitle"),
                }),
                s("section", {
                    t("\\section{"), i(1, "Section"), t("}"),
                }),
                s("subsection", {
                    t("\\subsection{"), i(1, "Subsection"), t("}"),
                }),
                s("begin", {
                    t("\\begin{"), i(1, "environment"), t({ "}", "" }),
                    i(2),
                    t({ "", "\\end{" }), i(3, "environment"), t("}"),
                }),
            })

            --- TODO: What is expand?
            vim.keymap.set({"i"}, "<C-s>e", function() ls.expand() end, {silent = true})

            vim.keymap.set({"i", "s"}, "<C-s>;", function() ls.jump(1) end, {silent = true})
            vim.keymap.set({"i", "s"}, "<C-s>,", function() ls.jump(-1) end, {silent = true})

            vim.keymap.set({"i", "s"}, "<C-E>", function()
                if ls.choice_active() then
                    ls.change_choice(1)
                end
            end, {silent = true})
        end,
    }
}
