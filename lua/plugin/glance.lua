local status, glance = pcall(require, "glance")
if not status then
	vim.notify("not found glance")
	return
end

glance.setup()
