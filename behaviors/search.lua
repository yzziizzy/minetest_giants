 
bt.register_action("FindNodeNear", {
	tick = function(node, data)
		if data.targetPos == nil then 
			print("could not find node near")
			return "failed" 
		end
		
		return "success"
	end,
	
	reset = function(node, data)
		local targetpos = minetest.find_node_near(data.pos, node.dist, node.sel)
		data.targetPos = targetpos
	end,
	
	ctor = function(sel, dist)
		return {
			dist = dist,
			sel = sel,
		}
	end,
})

bt.register_action("FindSpotOnGround", {
	tick = function(node, data)
		if data.targetPos == nil then 
			print("could not find spot on ground")
			return "failed" 
		end
		
		return "success"
	end,
	
	reset = function(node, data)
		-- really shitty quick hack
		local targetpos = minetest.find_node_near(data.pos, 2, {name="default:dirt_with_grass"})
		if targetpos ~= nil then
			targetpos.y = targetpos.y + 1
			data.targetPos = targetpos
		end
	end,
})


bt.register_action("FindNewNodeNear", {
	tick = function(node, data)
		if data.targetPos == nil then 
			print("could not find node near")
			return "failed" 
		end
		
		return "success"
	end,
	
	reset = function(node, data)
		local min_pos = {
			x = data.pos.x - node.dist,
			y = data.pos.y - node.dist,
			z = data.pos.z - node.dist,
		}
		local max_pos = {
			x = data.pos.x + node.dist,
			y = data.pos.y + node.dist,
			z = data.pos.z + node.dist,
		}
		
		data.targetPos = nil

		local list = minetest.find_nodes_in_area(min_pos, max_pos, node.sel)
		
		for _,p in ipairs(list) do
			local ps = p.x.."_"..p.y.."_"..p.z
			if data.history[ps] ~= true then
				
				data.history[ps] = true
				data.targetPos = p
				
				table.insert(data.history_queue, ps)
				break
			end
		end
		
		local len = table.getn(data.history_queue)
		if len >= data.history_depth then
			data.history[data.history_queue[1]] = nil
			table.remove(data.history_queue, 1)
		end
	end,
	
	ctor = function(sel, dist)
		return {
			dist = dist,
			sel = sel,
		}
	end,
})

bt.register_action("FindPath", {
	tick = function(node, data)
		if data.targetPos == nil or data.mob.path == nil then 
			return "failed" 
		end
		
		local d = distance(data.pos, data.targetPos)
		
		print("dist: "..d)
		
		if d <= .1 then
			print("arrived at target")
			return "success"
		end
		
		return "running"
	end,
	
	reset = function(node, data)
		if data.targetPos ~= nil then
			
			local path = minetest.find_path(data.pos, data.targetPos, node.searchDistance, node.maxJump, node.maxFall)
			
			data.mob.path = path
		else 
			print("FindPath: targetPos is nil")
		end
	end,
	
	ctor = function(searchDist, maxJump, maxFall)
		return {
			searchDist=searchDist or 10,
			maxJump=maxJump or 1,
			maxFall=maxFall or 3,
		}
	end,
})

 
bt.register_action("FindItemNear", {
	tick = function(node, data)
		
		if data.targetPos == nil and data.targetEntity == nil then
			return "failed"
		end
		
		return "success"
	end,
	
	reset = function(node, data)
		data.targetPos = nil
		data.targetEntity = nil
	
		local objects = minetest.get_objects_inside_radius(data.pos, node.dist)
		for _,object in ipairs(objects) do
			--tprint(object:get_luaentity())
			if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" then
				if object:get_luaentity().itemstring == node.sel then
					data.targetPos = object:getpos()
					data.targetEntity = object
					return
				end
			end
		end
	end,
	
	ctor = function(sel, dist)
		return {
			dist = dist,
			sel = sel,
		}
	end,
})



bt.register_action("AddToVisited", {
	tick = function(node, data)
		if data.targetPos == nil then 
			return "success" 
		end
		
		local p = data.targetPos
		local ps = p.x.."_"..p.y.."_"..p.z
		if data.history[ps] ~= true then
			data.history[ps] = true
			table.insert(data.history_queue, ps)
			
			local len = table.getn(data.history_queue)
			if len >= data.history_depth then
				data.history[data.history_queue[1]] = nil
				table.remove(data.history_queue, 1)
			end
		end
		
		return "success"
	end,
})

