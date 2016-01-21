
bt = {}
bt.reset = {}

bt.reset["repeat"]= function(...)
end


local bt_fns = {
	reset={},
	tick={},
}


-- nodes never call :reset() on themselves

--  distance on x-z plane
function distance(a, b) 
	local x = a.x - b.x
	local z = a.z - b.z
	
	return math.abs(math.sqrt(x*x + z*z))
end



function tprint (tbl, indent)
	local formatting = ""
  if not indent then indent = 0 end
  if tbl == nil then 
	  print(formatting .. "nil") 
	return
  end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))      
    elseif type(v) == 'function' then
      print(formatting .. "[function]")      
    elseif type(v) == 'userdata' then
      print(formatting .. "[userdata]")      
    else
      print(formatting .. v)
    end
  end
end


bt.register_action = function(name, def) 
	if type(def.reset) ~= "function" then
		bt_fns.reset[name] = function(node, data) end
	else 
		bt_fns.reset[name] = def.reset
	end
	
	if type(def.tick) ~= "function" then
		bt_fns.tick[name] = function(node, data) return "success" end
	else 
		bt_fns.tick[name] = def.tick
	end
	
	bt[name] = function(...) 
	
		local x = {}
		if type(def.ctor) == "function" then
			x = def.ctor(...)
		end
		
		x.kind = name
		if x.name == nil then
			x.name = name
		end
		
		return x
	end
	
end


bt.reset = function(node, data)
	return bt_fns.reset[node.kind](node, data)
end

bt.tick = function(node, data)
	return bt_fns.tick[node.kind](node, data)
end

local path = minetest.get_modpath("giants")

dofile(path..'/behaviors/core.lua')
dofile(path..'/behaviors/predicates.lua')










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




--[[
bt.reset.find_new_node_near = function(node, data)
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
		if not node.history[p] then
			
			node.history[p] = true
			data.targetPos = p
			
			table.insert(node.queue, p)
			break
		end
	end
	
	local len = table.getn(node.queue)
	if len > node.history_depth then
		node.history[node.queue[len] ] = nil
		table.remove(node.queue, 1)
	end
end

bt.tick.find_new_node_near = function(node, data)
	if data.targetPos == nil then 
		print("could not find node near")
		return "failed" 
	end
	
	return "success"
end


-- this is not working
function mkFindNewNodeNear(sel, dist, history_depth)
	
	return {
		name="find node near",
		kind="find_new_node_near",
		dist = dist,
		sel = sel,
		history_depth = history_depth,
		history = {},
		queue = {},
	}

end
]]


bt.register_action("Approach", {
	tick = function(node, data)
		if data.targetPos == nil then 
			return "failed" 
		end
		
		local d = distance(data.pos, data.targetPos)
		
		print("dist: "..d)
		
		if d <= node.dist then
			print("arrived at target")
			return "success"
		end
		
		return "running"
	end,
	
	reset = function(node, data)
		if data.targetPos ~= nil then
			print("Approaching target ("..data.targetPos.x..","..data.targetPos.y..","..data.targetPos.z..")")
			data.mob.destination = data.targetPos
		else 
			print("Approach: targetPos is nil")
		end
	end,
	
	ctor = function(dist)
		return {
			dist=dist,
		}
	end,
})



bt.register_action("TryApproach", {
	tick = function(node, data)
		if data.targetPos == nil then 
			return "failed" 
		end
		
		local d = distance(data.pos, data.targetPos)
		
		if d <= node.dist then
			print("arrived at target")
			node.last_d = nil
			return "success"
		end
		
		
		if node.last_d == nil then
			node.last_d = d
		else 
			local dd = math.abs(node.last_d - d)
			--print("last_d: " .. node.last_d .. " d: "..d.." dist: ".. dd)
			if dd < .02 then
				-- we're stuck
				node.last_d = nil
				return "failed"
			end
			
			node.last_d = d
		end

		return "running"
	end,
	
	reset = function(node, data)
		node.last_d = nil

		if data.targetPos ~= nil then
			print("Approaching target ("..data.targetPos.x..","..data.targetPos.y..","..data.targetPos.z..")")
			data.mob.destination = data.targetPos
		else 
			print("Approach: targetPos is nil")
		end
	end,
	
	ctor = function(dist)
		return {
			dist=dist,
		}
	end,
})




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





--[[
bt.register_action("", {
	tick = function(node, data)

	end,
	
	reset = function(node, data)

	end,
	
	ctor = function(sel, dist)

	end,
})
]]












--[[
ideas:
	RobChest(items, max) // robs nearby chests of given items
	PutInChest(items)
	ThrowAt(projectile, target)
	FleeFrom(pos, distance)
	FleeFromNodes(nodes, distance) -- gets distance away from any nodes
	FleeFromPlayer(entity, distance)
	ExtinguishFires() -- puts out nearby fires
	Stomp(pos) -- plays stomping animation and eventually destroys node
	DigNode(pos) -- digs node and adds drops to inventory
	Attack(entity) -- seek and kill entity
	FindNearbyEntity(entity_type)
	HealthBelow(n)
	HealthAbove(n)
		^ for heat, humidity, light, hunger, breath
	SetWaypoint(name) -- saves the current position as a named waypoint 
	SetWaypointPos(name) -- saves the target position as a named waypoint
	GoToWaypoint(name)
	TossNearbyEntity() -- tosses a nearby entity
	WaitTicks(n) -- return running for n ticks
	SetTimer/IsExpired/HasPassed(name, [number])

stack nodes to make stairs when pathfinding is broken
travel up ladders and through doors



]]