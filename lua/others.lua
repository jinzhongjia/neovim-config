local is_nixos = os.getenv("IsNixOS") == "1"

--- @return boolean
_G.isNixos = function()
   return is_nixos
end
