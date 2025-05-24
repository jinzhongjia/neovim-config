vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    vim.lsp.document_color.enable(true, args.buf)
  end
})
