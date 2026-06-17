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

local function resolve_environment(root)
    root = root or M.project_root()
    local cache_key = table.concat({
        root,
        vim.env.UV_PROJECT_ENVIRONMENT or "",
        vim.env.VIRTUAL_ENV or "",
        vim.env.CONDA_PREFIX or "",
    }, "\n")
    local cached = env_cache[cache_key]
    if cached then
        return cached.venv, cached.python
    end

    local candidates = {}

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
    end
end

function M.apply_ruff_init_options(config, root)
    config.init_options = config.init_options or {}
    config.init_options.settings = vim.tbl_deep_extend("force", config.init_options.settings or {}, {
        configurationPreference = "filesystemFirst",
        interpreter = { M.python_path(root) },
    })
end

return M
