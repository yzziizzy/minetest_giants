 
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
		targetpos.y = targetpos.y + 1
		data.targetPos = targetpos
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
			if node.history[ps] ~= true then
				
				node.history[ps] = true
				data.targetPos = p
				
				table.insert(node.queue, ps)
				break
			end
		end
		
		local len = table.getn(node.queue)
		if len >= node.history_depth then
			node.history[node.queue[1]] = nil
			table.remove(node.queue, 1)
		end
	end,
	
	ctor = function(sel, dist, history_depth)
		return {
			dist = dist,
			sel = sel,
			history_depth = history_depth,
			history = {},
			queue = {},
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


