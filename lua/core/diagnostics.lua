-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Diagnostics configuration (0.12 style)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local sev = vim.diagnostic.severity

vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  virtual_text = {
    spacing = 4,
    prefix = "●",
    -- Only show errors/warnings inline to reduce noise
    severity = { min = sev.WARN },
  },
  float = {
    border = "rounded",
    source = true,
    header = "",
    prefix = function(diag)
      local icons = {
        [sev.ERROR] = " ",
        [sev.WARN]  = " ",
        [sev.INFO]  = " ",
        [sev.HINT]  = " ",
      }
      return icons[diag.severity] or "● ", "DiagnosticSign" .. ({
        [sev.ERROR] = "Error",
        [sev.WARN]  = "Warn",
        [sev.INFO]  = "Info",
        [sev.HINT]  = "Hint",
      })[diag.severity]
    end,
  },
  signs = {
    text = {
      [sev.ERROR] = " ",
      [sev.WARN]  = " ",
      [sev.INFO]  = " ",
      [sev.HINT]  = " ",
    },
    -- 行号跟着诊断级别变色（sign 那一列已被 snacks statuscolumn 占着）
    numhl = {
      [sev.ERROR] = "DiagnosticSignError",
      [sev.WARN]  = "DiagnosticSignWarn",
      [sev.INFO]  = "DiagnosticSignInfo",
      [sev.HINT]  = "DiagnosticSignHint",
    },
  },
})

-- virtual_text 只显示第一行，长诊断（Go 泛型/类型不匹配那种）看不全；
-- gK 把当前行切成 virtual_lines 完整展开，再按一次收回
vim.keymap.set("n", "gK", function()
  local enabled = vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({ virtual_lines = not enabled and { current_line = true } or false })
end, { desc = "Toggle current line diagnostics (virtual_lines)" })
