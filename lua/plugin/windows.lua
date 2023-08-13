local status, windows = pcall(require, "windows")
if not status then
	vim.notify("not found windows")
	return
end

windows.setup()
