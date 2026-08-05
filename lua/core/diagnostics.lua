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
  },
})
