local status, hlargs = pcall(require, "hlargs")
if not status then
	vim.notify("not found hlargs")
	return
end

hlargs.setup()
