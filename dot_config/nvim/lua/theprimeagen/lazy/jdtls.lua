return {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
        local jdtls = require("jdtls")
        local setup = require("jdtls.setup")

        local root_dir = setup.find_root({ "cnf", "settings.gradle", "gradlew", ".git" })
        if not root_dir then
            return
        end

        local function path_exists(path)
            return vim.loop.fs_stat(path) ~= nil
        end

        local function basename(path)
            path = path:gsub("[/\\]$", "")
            return vim.fn.fnamemodify(path, ":t")
        end

        local function platform_config(jdtls_path)
            local uname = vim.loop.os_uname()
            local sysname = uname.sysname
            local machine = uname.machine

            if sysname == "Darwin" then
                if machine == "arm64" or machine == "aarch64" then
                    return jdtls_path .. "/config_mac_arm"
                end
                return jdtls_path .. "/config_mac"
            elseif sysname == "Linux" then
                if machine == "arm64" or machine == "aarch64" then
                    return jdtls_path .. "/config_linux_arm"
                end
                return jdtls_path .. "/config_linux"
            end

            return jdtls_path .. "/config_win"
        end

        local function collect_openems_libraries()
            local libraries = {}
            local seen = {}
            local cache_jars = vim.fn.glob(root_dir .. "/cnf/cache/**/*.jar", true, true)
            local generated_jars = vim.fn.glob(root_dir .. "/*/generated/*.jar", true, true)

            vim.list_extend(cache_jars, generated_jars)
            table.sort(cache_jars)

            local function add_library(path)
                if path ~= "" and path_exists(path) and not seen[path] then
                    seen[path] = true
                    table.insert(libraries, path)
                end
            end

            for _, jar in ipairs(cache_jars) do
                add_library(jar)
            end

            local pom = root_dir .. "/cnf/pom.xml"
            if path_exists(pom) then
                local m2 = vim.fn.expand("~/.m2/repository")
                local gradle_cache = vim.fn.expand("~/.gradle/caches/modules-2/files-2.1")
                local dependency = nil

                for _, line in ipairs(vim.fn.readfile(pom)) do
                    if line:find("<dependency>", 1, true) then
                        dependency = {}
                    elseif dependency and line:find("</dependency>", 1, true) then
                        if dependency.group and dependency.artifact and dependency.version then
                            local group_path = dependency.group:gsub("%.", "/")
                            add_library(table.concat({
                                m2,
                                group_path,
                                dependency.artifact,
                                dependency.version,
                                dependency.artifact .. "-" .. dependency.version .. ".jar",
                            }, "/"))

                            local gradle_jars = vim.fn.glob(table.concat({
                                gradle_cache,
                                dependency.group,
                                dependency.artifact,
                                dependency.version,
                                "*",
                                dependency.artifact .. "-" .. dependency.version .. ".jar",
                            }, "/"), true, true)

                            for _, jar in ipairs(gradle_jars) do
                                add_library(jar)
                            end
                        end

                        dependency = nil
                    elseif dependency then
                        dependency.group = dependency.group or line:match("<groupId>(.-)</groupId>")
                        dependency.artifact = dependency.artifact or line:match("<artifactId>(.-)</artifactId>")
                        dependency.version = dependency.version or line:match("<version>(.-)</version>")
                    end
                end
            end

            return libraries
        end

        local function collect_openems_source_paths(workspace_root)
            local source_paths = {}
            local seen = {}
            local source_dirs = vim.list_extend(
                vim.fn.glob(root_dir .. "/*/src", true, true),
                vim.fn.glob(root_dir .. "/*/test", true, true)
            )

            table.sort(source_dirs)

            for _, dir in ipairs(source_dirs) do
                local relative = vim.fs.relpath(workspace_root, dir) or dir
                if relative == "" then
                    relative = "."
                end
                if relative ~= "" and not seen[relative] then
                    seen[relative] = true
                    table.insert(source_paths, relative)
                end
            end

            return source_paths
        end

        local function java_capabilities()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")

            if ok then
                capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
            end

            return capabilities
        end

        local function current_bundle_name()
            local file = vim.api.nvim_buf_get_name(0)
            local dir = vim.fs.dirname(file)
            local bundle_dir = vim.fs.root(dir, { "bnd.bnd" })

            if not bundle_dir or bundle_dir == root_dir then
                return nil
            end

            return basename(bundle_dir)
        end

        local function current_bundle_source_root()
            local file = vim.api.nvim_buf_get_name(0)
            local dir = vim.fs.dirname(file)
            local bundle_dir = vim.fs.root(dir, { "bnd.bnd" })

            if not bundle_dir or bundle_dir == root_dir then
                return nil
            end

            for _, source_dir in ipairs({ bundle_dir .. "/src", bundle_dir .. "/test" }) do
                if file == source_dir or vim.startswith(file, source_dir .. "/") then
                    return source_dir
                end
            end

            return nil
        end

        local function run_gradle(args)
            vim.cmd("botright split")
            vim.cmd("resize 15")
            vim.fn.termopen(vim.list_extend({ "./gradlew" }, args), { cwd = root_dir })
            vim.cmd("startinsert")
        end

        local function run_bundle_task(task)
            local bundle = current_bundle_name()

            if not bundle then
                vim.notify("No OpenEMS bundle with bnd.bnd found for current file", vim.log.levels.WARN)
                return
            end

            run_gradle({ ":" .. bundle .. ":" .. task })
        end

        local function setup_openems_commands()
            if not path_exists(root_dir .. "/cnf/build.bnd") then
                return
            end

            vim.api.nvim_buf_create_user_command(0, "OpenemsCompile", function()
                run_bundle_task("compileJava")
            end, { desc = "Compile the current OpenEMS bundle", force = true })

            vim.api.nvim_buf_create_user_command(0, "OpenemsTest", function()
                run_bundle_task("test")
            end, { desc = "Run tests for the current OpenEMS bundle", force = true })

            vim.api.nvim_buf_create_user_command(0, "OpenemsBuildEdge", function()
                run_gradle({ "buildEdge" })
            end, { desc = "Build OpenEMS Edge", force = true })

            vim.api.nvim_buf_create_user_command(0, "OpenemsBuildBackend", function()
                run_gradle({ "buildBackend" })
            end, { desc = "Build OpenEMS Backend", force = true })
        end

        local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
        local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
        local lombok = jdtls_path .. "/lombok.jar"
        local is_openems = path_exists(root_dir .. "/cnf/build.bnd")
        local lsp_root_dir = is_openems and (current_bundle_source_root() or root_dir) or root_dir
        local project_name = basename(root_dir) .. "-" .. string.sub(vim.fn.sha256(lsp_root_dir), 1, 8)
        local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. project_name

        if launcher == "" then
            vim.notify("JDTLS launcher not found. Install it with :MasonInstall jdtls", vim.log.levels.ERROR)
            return
        end

        local cmd = {
            "java",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dorg.eclipse.jdt.core.compiler.problem.enablePreviewFeatures=disabled",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Xms1g",
            "-Xmx4g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens",
            "java.base/java.util=ALL-UNNAMED",
            "--add-opens",
            "java.base/java.lang=ALL-UNNAMED",
        }

        if path_exists(lombok) then
            table.insert(cmd, "-javaagent:" .. lombok)
        end

        vim.list_extend(cmd, {
            "-jar",
            launcher,
            "-configuration",
            platform_config(jdtls_path),
            "-data",
            workspace_dir,
        })

        setup_openems_commands()

        local java_settings = {
            server = {
                launchMode = is_openems and "Standard" or "Hybrid",
            },
            configuration = {
                updateBuildConfiguration = is_openems and "disabled" or "interactive",
            },
            import = {
                gradle = { enabled = not is_openems },
                maven = { enabled = not is_openems },
            },
            autobuild = {
                enabled = not is_openems,
            },
            signatureHelp = {
                enabled = true,
            },
            sources = {
                organizeImports = {
                    starThreshold = 9999,
                    staticStarThreshold = 9999,
                },
            },
        }

        if is_openems then
            java_settings.project = {
                importOnFirstTimeStartup = "disabled",
                outputPath = ".jdtls-bin",
                referencedLibraries = collect_openems_libraries(),
            }

            if lsp_root_dir == root_dir then
                java_settings.project.sourcePaths = collect_openems_source_paths(lsp_root_dir)
            else
                java_settings.project.sourcePaths = { "." }
            end
        end

        jdtls.start_or_attach({
            cmd = cmd,
            root_dir = lsp_root_dir,
            capabilities = java_capabilities(),
            settings = {
                java = java_settings,
            },
            init_options = {
                bundles = {},
            },
        })

        vim.keymap.set("n", "<leader>jo", jdtls.organize_imports, { buffer = true })
        vim.keymap.set("n", "<leader>jc", function()
            jdtls.compile("incremental")
        end, { buffer = true })
        vim.keymap.set("n", "<leader>jC", function()
            jdtls.compile("full")
        end, { buffer = true })
    end,
}
