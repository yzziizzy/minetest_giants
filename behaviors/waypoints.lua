 


bt.register_action("SetWaypointHere", {
	tick = function(node, data)
		local pos = {x= data.pos.x, y= data.pos.y, z= data.pos.z}
		data.waypoints[node.wpname] = pos
		return "success"
	end,
	
	ctor = function(name)
		return {
			wpname=name or "_"
		}
	end,
})

bt.register_action("SetWaypoint", {
	tick = function(node, data)
		if data.targetPos == nil then 
			return "failed" 
		end
		
		local pos = {x= data.targetPos.x, y= data.targetPos.y, z= data.targetPos.z}
		data.waypoints[node.wpname] = pos
		return "success"
	end,
	
	ctor = function(name)
		return {
			wpname=name or "_"
		}
	end,
})



bt.register_action("GetWaypoint", {
	tick = function(node, data)
		if data.waypoints[node.wpname] == nil then
			return "failed"
		end
	
		data.targetPos = data.waypoints[node.wpname]
		return "success"
	end,
	
	ctor = function(name)
		return {
			wpname=name or "_"
		}
	end,
})


bt.register_action("SetGroupWaypoint", {
	tick = function(node, data)
		if data.targetPos == nil or data.groupID == nil or giants.groupData[data.groupID] == nil then 
			return "failed" 
		end
		
		local pos = {x= data.targetPos.x, y= data.targetPos.y, z= data.targetPos.z}
		giants.groupData[data.groupID].waypoints[node.wpname] = pos
		return "success"
	end,
	
	ctor = function(name)
		return {
			wpname=name or "_"
		}
	end,
})

bt.register_action("GetGroupWaypoint", {
	tick = function(node, data)
		if data.groupID == nil 
			or giants.groupData[data.groupID] == nil 
			or giants.groupData[data.groupID].waypoints == nil
			or giants.groupData[data.groupID].waypoints[node.wpname] == nil then
			
			print(dump(giants.groupData[data.groupID]))
			print("!   failed to find group ("..data.groupID..") waypoint " .. node.wpname .. "\n")
			return "failed"
		end
	
		data.targetPos = giants.groupData[data.groupID].waypoints[node.wpname]
		return "success"
	end,
	
	ctor = function(name)
		return {
			wpname=name or "_"
		}
	end,
})






bt.register_action("CreatePathHere", {
	tick = function(node, data)
		if data.pos == nil then 
			return "failed" 
		end
		
		local pos = {x= data.pos.x, y= data.pos.y, z= data.pos.z}
		data.paths[node.pname] = {pos}
		return "success"
	end,
	
	ctor = function(name) return { pname=name or "_" } end,
})

bt.register_action("CreatePath", {
	tick = function(node, data)
		if data.targetPos == nil then 
			return "failed" 
		end
		
		local pos = {x= data.targetPos.x, y= data.targetPos.y, z= data.targetPos.z}
		data.paths[node.pname] = {pos}
		return "success"
	end,
	
	ctor = function(name) return { pname=name or "_" } end,
})

bt.register_action("AddPathNodeHere", {
	tick = function(node, data)
		if data.pos == nil then 
			return "failed" 
		end
		
		local pos = {x= data.pos.x, y= data.pos.y, z= data.pos.z}
		table.insert(data.paths[node.pname], pos)
		return "success"
	end,
	
	ctor = function(name) return { pname=name or "_" } end,
})

bt.register_action("AddPathNode", {
	tick = function(node, data)
		if data.targetPos == nil then 
			return "failed" 
		end
		
		local pos = {x= data.targetPos.x, y= data.targetPos.y, z= data.targetPos.z}
		table.insert(data.paths[node.pname], pos)
		return "success"
	end,
	
	ctor = function(name) return { pname=name or "_" } end,
})



