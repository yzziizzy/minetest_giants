local path = minetest.get_modpath("giants")

-- Mob Api

dofile(path.."/api.lua")
dofile(path.."/behavior.lua")
dofile(path.."/simple_api.lua")



dofile(path.."/giant.lua") 


-- Mob Items
--dofile(path.."/crafts.lua")

-- Spawner
--dofile(path.."/spawner.lua")

print ("[MOD] Giants loaded")