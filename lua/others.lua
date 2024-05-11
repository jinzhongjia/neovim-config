local is_nixos = os.getenv("IsNixOS") == "1"

--- @return boolean
_G.isNixos = function()
    return is_nixos
end

--- @param name string
--- @return boolean
_G.check_exec = function(name)
    return vim.fn.executable(name) == 1
end
