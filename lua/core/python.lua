local M = {}

M.root_markers = {
    "pyproject.toml",
    "uv.lock",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    ".git",
}

local is_windows = vim.fn.has("win32") == 1
local path_sep = is_windows and "\\" or "/"
local venv_bin = is_windows and "Scripts" or "bin"
local python_exe = is_windows and "python.exe" or "python"
local uv = vim.uv or vim.loop
local env_cache = {}
local refresh = {
    roots = {},
    group = nil,
}

local function joinpath(...)
    return table.concat(
        vim.tbl_filter(function(part)
            return part and part ~= ""
        end, { ... }),
        path_sep
    )
end

local function is_absolute(path)
    if not path or path == "" then
        return false
    end

    if is_windows then
        return path:match("^%a:[/\\]") ~= nil or path:match("^[/\\][/\\]") ~= nil
    end

    return vim.startswith(path, "/")
end

local function executable(path)
    return path and path ~= "" and vim.fn.executable(path) == 1
end

local function file_readable(path)
    return path and path ~= "" and vim.fn.filereadable(path) == 1
end

local function readable_dir(path)
    local stat = path and uv.fs_stat(path)
    return stat and stat.type == "directory"
end

local function add_candidate(candidates, path)
    if path and path ~= "" then
        table.insert(candidates, path)
    end
end

local function add_relative_candidate(candidates, root, path)
    if not path or path == "" then
        return
    end

    if is_absolute(path) then
        add_candidate(candidates, path)
    else
        add_candidate(candidates, joinpath(root, path))
    end
end

local function system_output(cmd, cwd)
    if vim.fn.executable(cmd[1]) ~= 1 then
        return
    end

    local ok, result = pcall(function()
        return vim.system(cmd, { cwd = cwd, text = true }):wait(2000)
    end)

    if ok and result and result.code == 0 then
        return vim.trim(result.stdout or "")
    end
end

local function executable_python(path)
    if executable(path) then
        return path
    end
end

local function command_python(cmd, root)
    return executable_python(system_output(cmd, root))
end

function M.project_root(fname)
    fname = fname and fname ~= "" and fname or vim.api.nvim_buf_get_name(0)
    return vim.fs.root(fname, M.root_markers) or vim.fn.getcwd()
end

function M.venv_python(venv)
    return joinpath(venv, venv_bin, python_exe)
end

function M.command_python(root)
    root = root or M.project_root()

    if file_readable(joinpath(root, ".envrc")) then
        local direnv_python =
            command_python({ "direnv", "exec", root, "python", "-c", "import sys; print(sys.executable)" }, root)
        if direnv_python then
            return direnv_python
        end
    end

    local poetry_python = command_python({ "poetry", "env", "info", "--executable" }, root)
    if poetry_python then
        return poetry_python
    end

    local pipenv_venv = system_output({ "pipenv", "--venv" }, root)
    if pipenv_venv and pipenv_venv ~= "" and readable_dir(pipenv_venv) then
        local pipenv_python = executable_python(M.venv_python(pipenv_venv))
        if pipenv_python then
            return pipenv_python
        end
    end

    local pdm_python = command_python({ "pdm", "run", "python", "-c", "import sys; print(sys.executable)" }, root)
    if pdm_python then
        return pdm_python
    end

    local hatch_python = command_python({ "hatch", "python", "-c", "import sys; print(sys.executable)" }, root)
    if hatch_python then
        return hatch_python
    end

    local pyenv_python = command_python({ "pyenv", "which", "python" }, root)
    if pyenv_python then
        return pyenv_python
    end
end

local function environment_cache_key(root)
    return table.concat({
        root,
        vim.env.UV_PROJECT_ENVIRONMENT or "",
        vim.env.VIRTUAL_ENV or "",
        vim.env.CONDA_PREFIX or "",
    }, "\n")
end

local function add_venv_candidates(candidates, root)
    add_relative_candidate(candidates, root, vim.env.UV_PROJECT_ENVIRONMENT)
    add_candidate(candidates, vim.env.VIRTUAL_ENV)
    add_candidate(candidates, vim.env.CONDA_PREFIX)

    -- uv / venv / virtualenv / pdm 默认都优先放在项目内。
    add_candidate(candidates, joinpath(root, ".venv"))
    add_candidate(candidates, joinpath(root, "venv"))
    add_candidate(candidates, joinpath(root, ".env"))
    add_candidate(candidates, joinpath(root, "env"))

    -- direnv 常见布局，不执行 shell hook，直接读取已 materialize 的虚拟环境。
    add_candidate(candidates, joinpath(root, ".direnv", "python-3.13"))
    add_candidate(candidates, joinpath(root, ".direnv", "python-3.12"))
    add_candidate(candidates, joinpath(root, ".direnv", "python-3.11"))
    add_candidate(candidates, joinpath(root, ".direnv", "python-3.10"))
    add_candidate(candidates, joinpath(root, ".direnv", "python-3.9"))
end

local function environment_signature(root)
    local candidates = {}
    local parts = { environment_cache_key(root) }

    add_venv_candidates(candidates, root)

    for _, venv in ipairs(candidates) do
        local stat = uv.fs_stat(M.venv_python(venv))
        parts[#parts + 1] = venv .. ":" .. (stat and stat.type or "")
    end

    return table.concat(parts, "\n")
end

local function close_handle(handle)
    if handle and not handle:is_closing() then
        handle:stop()
        handle:close()
    end
end

function M.clear_cache(root)
    if not root then
        env_cache = {}
        return
    end

    local prefix = root .. "\n"
    for key in pairs(env_cache) do
        if key == root or vim.startswith(key, prefix) then
            env_cache[key] = nil
        end
    end
end

local function resolve_environment(root)
    root = root or M.project_root()
    local cache_key = environment_cache_key(root)
    local cached = env_cache[cache_key]
    if cached then
        return cached.venv, cached.python
    end

    local candidates = {}
    add_venv_candidates(candidates, root)
    for _, venv in ipairs(candidates) do
        if readable_dir(venv) and executable(M.venv_python(venv)) then
            env_cache[cache_key] = { venv = venv }
            return venv, nil
        end
    end

    local python = M.command_python(root)
    env_cache[cache_key] = { python = python or false }
    return nil, python
end

function M.find_venv(root)
    local venv = resolve_environment(root)
    return venv
end

function M.python_path(root)
    local venv, command_path = resolve_environment(root)
    if venv then
        return M.venv_python(venv)
    end
    if command_path then
        return command_path
    end

    local python3 = vim.fn.exepath("python3")
    if python3 ~= "" then
        return python3
    end

    local python = vim.fn.exepath("python")
    return python ~= "" and python or "python"
end

function M.apply_lsp_settings(config, root)
    root = root or config.root_dir or M.project_root()
    local venv = M.find_venv(root)

    config.settings = config.settings or {}
    config.settings.python = vim.tbl_deep_extend("force", config.settings.python or {}, {
        pythonPath = M.python_path(root),
    })

    if venv then
        config.settings.python.venvPath = vim.fs.dirname(venv)
        config.settings.python.venv = vim.fs.basename(venv)
    else
        config.settings.python.venvPath = nil
        config.settings.python.venv = nil
    end
end

function M.apply_ruff_init_options(config, root)
    config.init_options = config.init_options or {}
    config.init_options.settings = vim.tbl_deep_extend("force", config.init_options.settings or {}, {
        configurationPreference = "filesystemFirst",
        interpreter = { M.python_path(root) },
    })
end

local function python_buffers(root)
    local buffers = {}

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[bufnr].filetype == "python" then
            local name = vim.api.nvim_buf_get_name(bufnr)
            if name ~= "" and M.project_root(name) == root then
                buffers[#buffers + 1] = bufnr
            end
        end
    end

    return buffers
end

local function client_uses_root(client, root)
    if client.config and client.config.root_dir == root then
        return true
    end

    for _, workspace in ipairs(client.workspace_folders or {}) do
        if workspace.name == root then
            return true
        end
    end

    return false
end

function M.refresh_lsp(root)
    M.clear_cache(root)

    for _, client in ipairs(vim.lsp.get_clients()) do
        if client_uses_root(client, root) then
            if client.name == "basedpyright" then
                M.apply_lsp_settings(client.config, root)
                client.notify("workspace/didChangeConfiguration", {
                    settings = client.config.settings or {},
                })
            elseif client.name == "ruff" then
                M.apply_ruff_init_options(client.config, root)
                client.notify("workspace/didChangeConfiguration", {
                    settings = client.config.init_options and client.config.init_options.settings or {},
                })
            end
        end
    end

    vim.cmd("redrawstatus")
end

local function close_root(root)
    local state = refresh.roots[root]
    if not state then
        return
    end

    for path, watcher in pairs(state.watchers) do
        close_handle(watcher)
        state.watchers[path] = nil
    end

    close_handle(state.debounce)
    refresh.roots[root] = nil
end

local function schedule_root_refresh(root)
    local state = refresh.roots[root]
    if not state then
        return
    end

    if not state.debounce then
        state.debounce = uv.new_timer()
    end

    state.debounce:stop()
    state.debounce:start(
        120,
        0,
        vim.schedule_wrap(function()
            if #python_buffers(root) == 0 then
                close_root(root)
                return
            end

            M.update_root_watches(root)

            local next_signature = environment_signature(root)
            if next_signature ~= state.signature then
                state.signature = next_signature
                M.refresh_lsp(root)
            end
        end)
    )
end

local function watch_path(root, path)
    local state = refresh.roots[root]
    if not state or state.watchers[path] or not readable_dir(path) then
        return
    end

    local watcher = uv.new_fs_event()
    if not watcher then
        return
    end

    local ok = watcher:start(path, {}, function(err)
        if err then
            close_handle(watcher)
            state.watchers[path] = nil
            return
        end

        schedule_root_refresh(root)
    end)

    if ok then
        state.watchers[path] = watcher
    else
        close_handle(watcher)
    end
end

function M.update_root_watches(root)
    watch_path(root, root)

    local candidates = {}
    add_venv_candidates(candidates, root)

    for _, venv in ipairs(candidates) do
        watch_path(root, venv)
        watch_path(root, joinpath(venv, venv_bin))
    end
end

local function watch_root(root)
    if not refresh.roots[root] then
        refresh.roots[root] = {
            signature = environment_signature(root),
            watchers = {},
        }
    end

    M.update_root_watches(root)
end

local function cleanup_unowned_roots()
    for root in pairs(refresh.roots) do
        if #python_buffers(root) == 0 then
            close_root(root)
        end
    end
end

function M.setup_auto_refresh()
    if refresh.group then
        return
    end

    refresh.group = vim.api.nvim_create_augroup("PythonVenvRefresh", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged", "FileType", "FocusGained" }, {
        group = refresh.group,
        callback = function(args)
            local bufnr = args.buf
            if bufnr and vim.bo[bufnr].filetype == "python" then
                local root = M.project_root(vim.api.nvim_buf_get_name(bufnr))
                watch_root(root)
                schedule_root_refresh(root)
            end
        end,
    })
    vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
        group = refresh.group,
        callback = cleanup_unowned_roots,
    })

    if vim.bo.filetype == "python" then
        local root = M.project_root(vim.api.nvim_buf_get_name(0))
        watch_root(root)
        schedule_root_refresh(root)
    end
end

return M
