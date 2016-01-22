 


bt.register_action("Destroy", {
	tick = function(node, data)
		print("Destroying target")
		if data.targetPos == nil then 
			return "failed" 
		end
		
		-- too far away
		if distance(data.targetPos, data.pos) > data.mob.reach then
			return "failed"
		end
		
		minetest.set_node(data.targetPos, {name="air"})
		
		return "success"
	end,
})




bt.register_action("BashWalls", {
	tick = function(node, data)
		local pos = minetest.find_node_near(data.pos, 2, {"default:wood"})
		if pos == nil then
			return "failed"
		end
			
		minetest.set_node(pos, {name="air"})
		
		return "success"
	end,
})





bt.register_action("SetFire", {
	tick = function(node, data)
		print("setting fire to target")
		if data.targetPos == nil then 
			return "failed" 
		end
		
		-- too far away
		if distance(data.targetPos, data.pos) > data.mob.reach then
			return "failed"
		end
		
		local pos = fire.find_pos_for_flame_around(data.targetPos)
		if pos ~= nil then
			minetest.set_node(pos, {name = "fire:basic_flame"})
		end
		
		return "success"
	end,
})


bt.register_action("SetNode", {
	tick = function(node, data)
		if data.targetPos == nil then 
			return "failed" 
		end
		
		minetest.set_node(data.targetPos, node.sel)
		
		return "success"
	end,
	
	ctor = function(sel)
		return {
			sel = sel
		}
	end,
})

bt.register_action("ExtinguishFire", {
	tick = function(node, data)
		print("Extinguishing nearby fire")
		
		local pos = minetest.find_node_near(data.pos, data.mob.reach, {"fire:basic_flame"})
		if pos == nil then 
			return "success" 
		end
		
		minetest.set_node(pos, {name = "air"})
		
		return "running"
	end,
})


bt.register_action("DigNode", {
	tick = function(node, data)
		if data.targetPos == nil then 
			return "failed" 
		end
		
		minetest.dig_node(data.targetPos, nil, data.mob.object)
		
		return "success"
	end,
})

bt.register_action("PutInChest", {
	tick = function(node, data)
		if data.targetPos == nil then
			return "failed"
		end

		local inv = minetest.get_inventory({type="node", pos=data.targetPos}) 
		if inv == nil then 
			return "failed"
		end
		
		local items = data.inv:remove_items("main", node.sel)
		if items == nil then
			return "success"
		end
		
		local leftovers = inv:add_items("main", items) 
		
		if leftovers ~= nil and table.getn(leftover) > 0 then
			return "failed"
		end
		
		return "success"
	end,
	
	ctor = function(sel)
		return {
			sel = sel
		}
	end,
})