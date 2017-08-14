local path = minetest.get_modpath("giants")

giants = {
	groupData= {},
	mobsAlive= {},
}



local mod_storage = minetest.get_mod_storage()
 
local storagedata = mod_storage:to_table() -- Assuming there are only messages in the mod configuration
if storagedata ~= nil and storagedata.groupData ~= nil then
	giants = storagedata
end


minetest.register_on_shutdown(function()
	mod_storage:from_table(giants)
end)


-- Mob Api

dofile(path.."/api.lua")
dofile(path.."/behavior.lua")
dofile(path.."/simple_api.lua")



dofile(path.."/giant.lua") 


minetest.register_node("giants:campfire", {
	description = "Campfire",
	drawtype = "firelike",
	tiles = {
		{
			name = "fire_basic_flame_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	inventory_image = "fire_basic_flame.png",
	paramtype = "light",
	light_source = 13,
	walkable = false,
	buildable_to = false,
	sunlight_propagates = true,
	damage_per_second = 8,
	groups = {igniter = 2, cracky=3},
	drop = "",
	on_construct = function(pos)
		local key = pos.x..":"..pos.y..":"..pos.z
		if giants.groupData[key] == nil then
			giants.groupData[key] = {
				pos = {x= pos.x, y= pos.y, z= pos.z},
				roles = {},
				members = {},
				waypoints = {},
			}
		end
	end,
})


minetest.register_abm({
	label = "Smoke",
	nodenames = {"giants:campfire"},
	interval = 5,
	chance = 0,
	action = function(pos)
		pos.y = pos.y + 1
		minetest.add_particlespawner({
			amount = 4,
			time = 5,
			minpos = vector.subtract(pos, 1 / 4),
			maxpos = vector.add(pos, 1 / 4),
			minvel = {x=-0.05, y=.5, z=-0.05},
			maxvel = {x=0.05,  y=1.5,  z=0.05},
			minacc = {x=-0.05, y=0.1, z=-0.05},
			maxacc = {x=0.05, y=0.3, z=0.05},
			minexptime = 7,
			maxexptime = 12,
			minsize = 5,
			maxsize = 8,
			texture = "tnt_smoke.png^[colorize:black:120",
		})
	end,
})



-- Mob Items
--dofile(path.."/crafts.lua")

-- Spawner
--dofile(path.."/spawner.lua")

print ("[MOD] Giants loaded")
