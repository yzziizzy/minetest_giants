 


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
		
		local n = minetest.get_node_or_nil(data.targetPos)
		if n == nil then
			return "success"
		end
		
		local drops = minetest.get_node_drops(n.name)
		for _,i in ipairs(drops) do
			data.inv:add_item("main", i)
		end
		
		minetest.remove_node(data.targetPos)
		
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
		
		local list = data.inv:get_list("main")
		if list == nil then
			return "success"
		end
		local to_move = {}
		for k,i in ipairs(list) do
			print(i:get_name())
			if i:get_name() == node.sel then
				print("adding item")
				inv:add_item("main", i)
				list[k] = nil
				--table.insert(to_move, i)
			end
		end
		

		data.inv:set_list("main", list)
		--local leftovers = inv:add_item("main", items) 
		
		
		return "success"
	end,
	
	ctor = function(sel)
		return {
			sel = sel
		}
	end,
})