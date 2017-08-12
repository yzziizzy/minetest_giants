 





bt.register_action("IsDaytime", {
	tick = function(node, data)
		local tod = minetest.get_timeofday() * 24000
		if tod > 6000 and tod < 18000 then
			return "success"
		end
		
		return "failed"
	end,
})



bt.register_action("HealthAbove", {
	tick = function(node, data)
		local hp = data.mob.entity:get_hp()
		if hp >= node.n then
			return "success"
		end
		
		return "failed"
	end,
	
	ctor = function(n) 
		return {
			n = n
		}
	end,
})

bt.register_action("HealthBelow", {
	tick = function(node, data)
		local hp = data.mob.object:get_hp()
		if hp < node.n then
			return "success"
		end
		
		return "failed"
	end,
	
	ctor = function(n) 
		return {
			n = n
		}
	end,
})



bt.register_action("LightAbove", {
	tick = function(node, data)
		local l = minetest.get_node_light(data.pos, nil)
		if l >= node.n then
			return "success"
		end
		
		return "failed"
	end,
	
	ctor = function(n) 
		return {
			n = n
		}
	end,
})

bt.register_action("LightBelow", {
	tick = function(node, data)
		local l = minetest.get_node_light(data.pos, nil)
		if l < node.n then
			return "success"
		end
		
		return "failed"
	end,
	
	ctor = function(n) 
		return {
			n = n
		}
	end,
})

bt.register_action("CarryingItems", {
	tick = function(node, data)
		if data.inv:contains("main", node.items) then
			return "success"
		end
		
		return "failed"
	end,
	
	ctor = function(items, minCnt) 
		return {
			items=items,
		}
	end,
})


bt.register_action("NodeIsFull", {
	tick = function(node, data)
		if data.targetPos == nil then
			return "success"
		end
	
		local inv = minetest.get_inventory({type="node", pos=data.targetPos}) 
		if inv == nil then 
			return "success"
		end
		
		local sz = inv:get_size("main")
		local list = inv:get_list("main")
		
		if table.getn(list) < sz then
			return "failed"
		end
		
		return "success"
	end,
})
