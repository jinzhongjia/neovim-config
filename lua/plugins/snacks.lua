-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- snacks.nvim — folke 的工具集合，这里当"基础设施"用
-- 接管：picker（替掉 fzf-lua）、terminal、statuscolumn、
--       vim.ui.input/select、通知、indent 缩进线、bigfile/quickfile
-- 关掉：dashboard / explorer（文件树仍是 nvim-tree）/ scroll（动画拖性能）
-- 必须在其它插件配置之前 setup：todo-comments 要靠 Snacks 存在才注册
-- 它的 picker source；bigfile/quickfile 也得早于读文件的那批 autocmd。
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Go 生成物：protoc / connect / 各种 codegen 出来的文件，搜索里全是噪音
local go_generated = { "*.gen.go", "gen.go", "*.pb.go", "*.connect.go", "*.connector.go" }
local go_generated_patterns = {
    "%.gen%.go$",
    "/gen%.go$",
    "%.pb%.go$",
    "%.connect%.go$",
    "%.connector%.go$",
}

require("snacks").setup({
    -- ── 读文件相关 ────────────────────────────────────────────
    bigfile = { enabled = true }, -- 大文件关掉 treesitter/LSP/语法
    quickfile = { enabled = true }, -- 插件加载完之前先把文件画出来

    -- ── 编辑器增强 ────────────────────────────────────────────
    indent = {
        enabled = true,
        animate = { enabled = false }, -- 动画纯装饰，滚动时白耗 CPU
    },
    scope = { enabled = true }, -- ii/ai 作用域 textobject + [i/]i 跳转
    words = { enabled = true }, -- LSP 同名符号高亮，]]/[[ 跳转
    input = { enabled = true }, -- vim.ui.input 浮窗（rename 等）
    scratch = { enabled = true }, -- 带持久化文件的草稿 buffer
    bufdelete = { enabled = true }, -- 关 buffer 不打乱窗口布局
    git = { enabled = true },
    gitbrowse = { enabled = true }, -- 在浏览器打开当前行对应的远端页面
    zen = { enabled = true },
    dim = { enabled = true },
    toggle = { enabled = true, which_key = true },

    -- ── 通知 ──────────────────────────────────────────────────
    notifier = {
        enabled = true,
        timeout = 3000,
        style = "compact",
        icons = {
            error = " ",
            warn = " ",
            info = " ",
            debug = " ",
            trace = " ",
        },
    },

    -- ── statuscolumn：mark/sign 在左，fold/git 在右 ────────────
    -- git 那栏认 MiniDiffSign（mini.diff 的 sign 名），所以 hunk 标记
    -- 会落到右侧；options.lua 里 foldcolumn 必须非 "0"，否则不画折叠图标
    statuscolumn = {
        enabled = true,
        left = { "mark", "sign" },
        right = { "fold", "git" },
        folds = {
            open = true, -- 展开的折叠也画图标（默认只画折叠起来的）
            git_hl = true, -- 折叠图标跟随 git 颜色
        },
    },

    -- ── Picker（替代 fzf-lua，纯 Lua，无外部 fzf 依赖）─────────
    picker = {
        enabled = true,
        win = {
            input = {
                -- 预览执行 normal! 定位时，保留输入光标在行尾后一格的位置。
                wo = { virtualedit = "onemore" },
            },
        },
        -- ui_select 默认开：vim.ui.select 走 snacks 浮窗
        sources = {
            files = { hidden = true, exclude = go_generated }, -- 跟旧的 fd --hidden 行为一致
            git_files = { exclude = go_generated },
            grep = { hidden = true, exclude = go_generated },
            grep_word = { exclude = go_generated },
            grep_buffers = { exclude = go_generated },
            -- smart 继承 files，不用另配；recent 走的是 oldfiles 列表，
            -- exclude 那套 glob 不生效，只能用 filter 自己判路径
            recent = {
                filter = {
                    filter = function(item)
                        local path = item.file or item.text or ""
                        for _, pat in ipairs(go_generated_patterns) do
                            if path:match(pat) then
                                return false
                            end
                        end
                        return true
                    end,
                },
            },
        },
    },

    -- ── 终端 ──────────────────────────────────────────────────
    -- 浮窗尺寸不写在 styles.terminal 里：claudecode 也复用 Snacks.terminal，
    -- 全局样式会污染它右侧的 split；参数改在 plugins/terminal.lua 里按次传
    terminal = { enabled = true },

    -- ── 明确关掉的 ────────────────────────────────────────────
    dashboard = { enabled = false }, -- 不要启动页
    explorer = { enabled = false }, -- 文件树用 nvim-tree
    scroll = { enabled = false }, -- 平滑滚动动画影响性能
    rename = { enabled = false }, -- nvim-tree 自带 LSP 改名通知
    image = { enabled = false },

    -- ── 浮窗样式 ──────────────────────────────────────────────
    styles = {
        notification = { wo = { wrap = true } },
        scratch = {
            border = "rounded",
            width = 0.8,
            height = 0.8,
        },
        zen = { width = 120 },
    },
})

local map = vim.keymap.set
local P = function(source, opts)
    return function()
        Snacks.picker[source](opts)
    end
end

-- ── Picker：文件（键位同 main 的 fff/floaterm 布局）──────────
map("n", "<leader>ff", P("files"), { desc = "Find files" })
map("n", "<leader>fF", P("files", { hidden = true, ignored = true }), { desc = "Find files (all)" })
map("n", "<leader>fr", P("recent"), { desc = "Recent files" })
map("n", "<leader>fb", P("buffers"), { desc = "Buffers" })
map("n", "<leader>fh", P("help"), { desc = "Help tags" })
-- fk/fc/ft/fj/fs 归终端（同 main floaterm，见 plugins/terminal.lua）
map("n", "<leader>fK", P("keymaps"), { desc = "Keymaps" })
map("n", "<leader>fC", P("commands"), { desc = "Commands" })
map("n", "<leader>fR", P("resume"), { desc = "Resume last picker" })
map("n", "<leader>tt", P("pickers"), { desc = "All pickers" })

-- ── Picker：搜索（同 main：fg / fG / <leader>/ / <leader>*）──
map("n", "<leader>fg", P("grep"), { desc = "Live grep" })
map("v", "<leader>fg", P("grep_word"), { desc = "Grep selection" })
map("n", "<leader>fG", P("grep", { hidden = true, ignored = true }), { desc = "Grep (all)" })
map("n", "<leader>/", P("grep"), { desc = "Live grep" })
map("n", "<leader>*", P("grep_word"), { desc = "Grep cursor word" })
map("n", "<leader>sW", function()
    Snacks.picker.grep({ search = vim.fn.expand("<cWORD>") })
end, { desc = "Grep WORD" })
map("n", "<leader>sb", P("lines"), { desc = "Grep current buffer" })
map("n", "<leader>sB", P("grep_buffers"), { desc = "Grep open buffers" })

-- ── Picker：LSP 符号 / 诊断（同 main：ss/sS/sd/sD）────────────
-- 定义/引用/实现跳转走 LspUI <leader>gd/gr/gi（plugins/lspui.lua）
map("n", "<leader>ss", P("lsp_symbols"), { desc = "Document symbols" })
map("n", "<leader>sS", P("lsp_workspace_symbols"), { desc = "Workspace symbols" })
map("n", "<leader>sd", P("diagnostics_buffer"), { desc = "Document diagnostics" })
map("n", "<leader>sD", P("diagnostics"), { desc = "Workspace diagnostics" })

-- ── Picker：Git（<leader>g* 归 LSP，git picker 用 <leader>G*）─
map("n", "<leader>Gl", P("git_log"), { desc = "Git log (commits)" })
map("n", "<leader>Gs", P("git_status"), { desc = "Git status (picker)" })
map("n", "<leader>GB", P("git_branches"), { desc = "Git branches" })
map({ "n", "v" }, "<leader>Gy", function()
    Snacks.gitbrowse()
end, { desc = "Git browse (open remote)" })

-- ── 通知 / 草稿 ───────────────────────────────────────────────
map("n", "<leader>sn", function()
    Snacks.notifier.show_history()
end, { desc = "Notification history" })
map("n", "<leader>N", function()
    Snacks.notifier.hide()
end, { desc = "Dismiss notifications" })
map("n", "<leader>.", function()
    Snacks.scratch()
end, { desc = "Scratch buffer" })
map("n", "<leader>S", function()
    Snacks.scratch.select()
end, { desc = "Select scratch buffer" })

-- ── Zen / Zoom ────────────────────────────────────────────────
map("n", "<leader>zz", function()
    Snacks.zen()
end, { desc = "Zen mode" })
map("n", "<leader>zw", function()
    Snacks.zen.zoom()
end, { desc = "Zoom current window" })

-- ── words：同名符号跳转（覆盖内置的段落移动 [[/]]）────────────
map("n", "]]", function()
    Snacks.words.jump(vim.v.count1)
end, { desc = "Next reference" })
map("n", "[[", function()
    Snacks.words.jump(-vim.v.count1)
end, { desc = "Prev reference" })

-- ── 开关（<leader>T）─────────────────────────────────────────
Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>Ts")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>Tw")
Snacks.toggle.option("conceallevel", { off = 0, on = 2, name = "Conceal" }):map("<leader>Tc")
Snacks.toggle.line_number():map("<leader>Tl")
Snacks.toggle.diagnostics():map("<leader>Td")
Snacks.toggle.treesitter():map("<leader>Tt")
Snacks.toggle.indent():map("<leader>Ti")
-- inlay hints 已有 <leader>ih（core/lsp.lua），不再重复
Snacks.toggle.dim():map("<leader>TD")
