 
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


function vector_sub(a, b)
	return {
		x = a.x - b.x,
		y = a.y - b.y,
		z = a.z - b.z,
	}
end

function vector_len(a)
	return math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
end

function vector_normalize(a) 
	local len = vector_len(a)
	if len == 0 then
		print("attempting to normalize zero-length vector\n")
		len = 1 -- just do something kinda sorta sane so we don't div/0. 
	end
	return {
		x = a.x / len,
		y = a.y / len,
		z = a.z / len,
	}
end

function round(x)
	return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end


bt.register_action("DirectionTo", {
	tick = function(node, data)
		if data.targetPos == nil then 
			print("no target position\n")
			return "failed" 
		end

		if data.waypoints[node.wpname] == nil then 
			print("no such waypoint: " .. node.wpname .. "\n")
			return "failed" 
		end
		
		return "success"
	end,
	
	reset = function(node, data)
		local wp = data.waypoints[node.wpname]
		local diff = vector_sub(wp, data.targetPos)
		
		data.direction = vector_normalize(diff)
	end,
	
	ctor = function(wpname) return { wpname= wpname } end,
})


bt.register_action("RandomDirection", {
	tick = function(node, data)
		return "success"
	end,
	
	reset = function(node, data)
		data.direction = vector_normalize({
			x = math.random() * 2 - 1,
			y = 0,
			z = math.random() * 2 - 1,
		})
	end,
})

bt.register_action("MoveInDirection", {
	tick = function(node, data)
		if data.direction == nil then 
			print("no current direction \n")
			return "failed" 
		end
		
		return "success"
	end,
	
	reset = function(node, data)
		data.targetPos = {
			x = round(data.pos.x + (data.direction.x * node.dist)),
			y = round(data.pos.y + (data.direction.y * node.dist)),
			z = round(data.pos.z + (data.direction.z * node.dist)),
		}
	end,
	
	ctor = function(dist) return { dist= dist } end,
})

bt.register_action("MoveInDirectionFromWaypoint", {
	tick = function(node, data)
		if data.waypoints[node.wpname] == nil then 
			print("no such waypoint: " .. node.wpname .. "\n")
			return "failed" 
		end

		if data.direction == nil then 
			print("no current direction \n")
			return "failed" 
		end
		
		return "success"
	end,
	
	reset = function(node, data)
		local pos = data.waypoints[node.wpname]
		data.targetPos = {
			x = round(pos.x + data.direction.x * node.dist),
			z = round(pos.y + data.direction.y * node.dist),
			y = round(pos.z + data.direction.z * node.dist),
		}
	end,
	
	ctor = function(wpname, dist) 
		return { 
			wpname= wpname, 
			dist= dist, 
		} 
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


bt.register_action("FindAreaCorners", {
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
	
	ctor = function(sel, dist)
		return {
			dist = dist,
			sel = sel,
		}
	end,
})




bt.register_action("MoveTarget", {
	tick = function(node, data)
		if data.targetPos == nil then 
			print("no active target")
			return "failed" 
		end
		
		return "success"
	end,
	
	reset = function(node, data)
		if data.targetPos == nil then -- game restarts cause this
			return
		end
		
		data.targetPos.x = data.targetPos.x + node.scale.x
		data.targetPos.y = data.targetPos.y + node.scale.y
		data.targetPos.z = data.targetPos.z + node.scale.z
	end,
	
	ctor = function(scale)
		return {
			scale = scale,
		}
	end,
})


bt.register_action("MoveTargetRandom", {
	tick = function(node, data)
		if data.targetPos == nil then 
			print("no active target")
			return "failed" 
		end
		
		return "success"
	end,
	
	reset = function(node, data)
		if data.targetPos == nil then -- game restarts cause this
			return
		end
		
		data.targetPos.x = data.targetPos.x + math.random(-node.range.x, node.range.x)
		data.targetPos.y = data.targetPos.y + math.random(-node.range.y, node.range.y)
		data.targetPos.z = data.targetPos.z + math.random(-node.range.z, node.range.z)
	end,
	
	ctor = function(range)
		return {
			range = range,
		}
	end,
})


-- used for group identity
bt.register_action("FindGroupCampfire", {
	tick = function(node, data)
		if data.groupID ~= nil then -- already has a group
			if giants.groupData[data.groupID] ~= nil then
				print("@  joined group " .. data.groupID .. "\n")
				print(dump(giants.groupData[data.groupID]))
				return "success"
			end
		end
		
		local cf = minetest.find_node_near(data.pos, 50, {name="giants:campfire"})
		if cf ~= nil then
			local key = cf.x..":"..cf.y..":"..cf.z
			
			if giants.groupData[key] == nil then
				print(dump(giants))
-- 				print(dump(giants.groupData))
				print("!   failed to find group for key "..key.."\n")
				return "failed"
			end
			
			data.groupID = key
			print("@  joined group 2 " .. key .. "\n")
			print(dump(giants.groupData[data.groupID]))
			return "success"
		else
			print("!   failed to find group\n")
			return "failed"
		end
	end,
})

bt.register_action("HasGroup", {
	tick = function(node, data)
		if data.groupID ~= nil then -- already has a group
			if giants.groupData[data.groupID] ~= nil then
				return "success"
			end
		end
		
		return "failed"
	end,
})

