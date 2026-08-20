return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
        local function register_nvim_012_query_compat()
            if vim.fn.has("nvim-0.12") == 0 then
                return
            end

            local query = require("vim.treesitter.query")
            local opts = { force = true, all = false }

            local html_script_type_languages = {
                ["importmap"] = "json",
                ["module"] = "javascript",
                ["application/ecmascript"] = "javascript",
                ["text/ecmascript"] = "javascript",
            }

            local non_filetype_match_injection_language_aliases = {
                ex = "elixir",
                pl = "perl",
                sh = "bash",
                uxn = "uxntal",
                ts = "typescript",
            }

            local function first_node(match, capture_id)
                local nodes = match[capture_id]
                if type(nodes) == "table" then
                    return nodes[1]
                end
                return nodes
            end

            local function get_parser_from_markdown_info_string(injection_alias)
                local match = vim.filetype.match({ filename = "a." .. injection_alias })
                return match or non_filetype_match_injection_language_aliases[injection_alias] or injection_alias
            end

            local function report_arg_error(name, pred, count, strict_count)
                local arg_count = #pred - 1

                if strict_count and arg_count ~= count then
                    vim.api.nvim_err_writeln(string.format("%s must have exactly %d arguments", name, count))
                    return false
                elseif not strict_count and arg_count < count then
                    vim.api.nvim_err_writeln(string.format("%s must have at least %d arguments", name, count))
                    return false
                end

                return true
            end

            query.add_predicate("nth?", function(match, _, _, pred)
                if not report_arg_error("nth?", pred, 2, true) then
                    return
                end

                local node = first_node(match, pred[2])
                local n = tonumber(pred[3])
                if node and node:parent() and node:parent():named_child_count() > n then
                    return node:parent():named_child(n) == node
                end

                return false
            end, opts)

            query.add_predicate("is?", function(match, _, bufnr, pred)
                if not report_arg_error("is?", pred, 2) then
                    return
                end

                local node = first_node(match, pred[2])
                local types = { unpack(pred, 3) }
                if not node then
                    return true
                end

                local _, _, kind = require("nvim-treesitter.locals").find_definition(node, bufnr)
                return vim.tbl_contains(types, kind)
            end, opts)

            query.add_predicate("kind-eq?", function(match, _, _, pred)
                if not report_arg_error(pred[1], pred, 2) then
                    return
                end

                local node = first_node(match, pred[2])
                local types = { unpack(pred, 3) }
                if not node then
                    return true
                end

                return vim.tbl_contains(types, node:type())
            end, opts)

            query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
                local node = first_node(match, pred[2])
                if not node then
                    return
                end

                local type_attr_value = vim.treesitter.get_node_text(node, bufnr)
                local configured = html_script_type_languages[type_attr_value]
                if configured then
                    metadata["injection.language"] = configured
                else
                    local parts = vim.split(type_attr_value, "/", {})
                    metadata["injection.language"] = parts[#parts]
                end
            end, opts)

            query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
                local node = first_node(match, pred[2])
                if not node then
                    return
                end

                local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()
                metadata["injection.language"] = get_parser_from_markdown_info_string(injection_alias)
            end, opts)

            query.add_directive("make-range!", function() end, opts)

            query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
                local id = pred[2]
                local node = first_node(match, id)
                if not node then
                    return
                end

                local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ""
                if not metadata[id] then
                    metadata[id] = {}
                end
                metadata[id].text = string.lower(text)
            end, opts)
        end

        register_nvim_012_query_compat()

        require("nvim-treesitter.configs").setup({
            -- A list of parser names, or "all"
            ensure_installed = {
                "vimdoc", "javascript", "typescript", "c", "lua", "rust",
                 "bash", "bibtex", "c_sharp", "java", "properties", "xml",
            },
            ignore_install = { "latex" },

            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don"t have `tree-sitter` CLI installed locally
            auto_install = true,

            indent = {
                enable = true
            },

            highlight = {
                -- `false` will disable the whole extension
                enable = true,

                -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                -- Set this to `true` if you depend on "syntax" being enabled (like for indentation).
                -- Using this option may slow down your editor, and you may see some duplicate highlights.
                -- Instead of true it can also be a list of languages
                additional_vim_regex_highlighting = { "markdown" },
            },
        })

        local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
        treesitter_parser_config.templ = {
            install_info = {
                url = "https://github.com/vrischmann/tree-sitter-templ.git",
                files = {"src/parser.c", "src/scanner.c"},
                branch = "master",
            },
        }

        vim.treesitter.language.register("templ", "templ")
    end
}
