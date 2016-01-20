

bt = {
	reset={},
	tick={},
}





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


function mkSelector(name, list)
	
	return {
		name=name,
		kind="selector",
		current_kid=-1,
		kids=list,

	}
end


function mkSequence(name, list)
	
	return {
		name=name,
		kind="sequence",
		current_kid=-1,
		kids=list,

	}
	
	
end

--  -1 times is forever 
function mkRepeat(name, times, what)
	
	local x = {
		name=name,
		kind="repeat",
		kids = what,
	}
	
	if type(times) == "function" then
		x.times_fn = times
	elseif times == nil then
		x.times = -1
	else
		x.times = times
	end
	
	return x
end



bt.reset["repeat"] = function(node, data)
	node.count = 0
	if node.times_fn then
		node.times = node.times_fn()
	end
end

bt.tick["repeat"] = function(node, data)
	--tprint(node)
	if node.times ~= -1 then
		node.count = node.count + 1
		if node.count > node.times then
			return "success"
		end
	end

	local ret = bt.tick[node.kids[1].kind](node.kids[1], data)
	if ret ~= "running" then
		bt.reset[node.kids[1].kind](node.kids[1], data)
	end


	return "success"
end


-- nodes never call :reset() on themselves


bt.reset.selector = function(node, data)
	print("selector resetting")
	node.current_kid = -1
end

bt.tick.selector = function(node, data) 
	
	local ret
	
	if node.current_kid  == -1 then
		node.current_kid = 1
		ret = "failed" -- trick reset into being run
	end
	
	while node.current_kid <= table.getn(node.kids) do
	
		local cn = node.kids[node.current_kid]
		
		-- reset fresh nodes
		if ret == "failed" then
			print("resetting kid "..node.current_kid)
			bt.reset[cn.kind](cn, data)
		end
		
		-- tick the current node
		ret = bt.tick[cn.kind](cn, data)
		print(" selector '"..node.name.."' got status ["..ret.."] from kid "..node.current_kid)
		if ret == "running" or ret == "success" then
			return ret
		end
		
		node.current_kid = node.current_kid  + 1
	end
		
	
	return "failed"
end


bt.reset.sequence = function(node, data)
	node.current_kid = -1
end

bt.tick.sequence = function(node, data) 
	
	local ret
	
	if node.current_kid  == -1 then
		node.current_kid = 1
		ret = "success" -- trick reset into being run
	end
	
	while node.current_kid <= table.getn(node.kids) do
	
		local cn = node.kids[node.current_kid]
		
		-- reset fresh nodes
		if ret == "success" then
			bt.reset[cn.kind](cn, data)
		end
		
		-- tick the current node
		ret = bt.tick[cn.kind](cn, data)
		print(" sequence '"..node.name.."' got status ["..ret.."] from kid "..node.current_kid)
		if ret == "running" or ret == "failed" then
			return ret
		end
		
		node.current_kid = node.current_kid  + 1
	end
	
	return "success"
end



--  distance on x-z plane
function distance(a, b) 
	local x = a.x - b.x
	local z = a.z - b.z
	
	return math.abs(math.sqrt(x*x + z*z))
end


bt.reset.find_node_near = function(node, data)

	local targetpos = minetest.find_node_near(data.pos, node.dist, node.sel)
	data.targetPos = targetpos
end

bt.tick.find_node_near = function(node, data)
	if data.targetPos == nil then 
		print("could not find node near")
		return "failed" 
	end
	
	return "success"
end

function mkFindNodeNear(sel, dist)
	
	return {
		name="find node near",
		kind="find_node_near",
		dist = dist,
		sel = sel,
	}

end



bt.reset.approach = function(node, data) 
			
	if data.targetPos ~= nil then
		print("Approaching target ("..data.targetPos.x..","..data.targetPos.y..","..data.targetPos.z..")")
		data.mob.destination = data.targetPos
	else 
		print("Approach: targetPos is nil")
	end
end

bt.tick.approach = function(node, data) 
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
end


function mkApproach(dist)
	
	return {
		name="go to",
		kind="approach",
		dist=dist,
	}

end

function mkTryApproach(dist)
	
	return {
		name="try to go to",
		kind="try_approach",
		dist=dist,
	}

end

bt.reset.try_approach = function(node, data) 

	node.last_d = nil

	if data.targetPos ~= nil then
		print("Approaching target ("..data.targetPos.x..","..data.targetPos.y..","..data.targetPos.z..")")
		data.mob.destination = data.targetPos
	else 
		print("Approach: targetPos is nil")
	end
end

bt.tick.try_approach = function(node, data) 
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
	
	--print("dist: ".. math.abs(node.last_d - d))
	

	
	return "running"
end


bt.reset.destroy = function(node, data) 
	
end

bt.tick.destroy = function(node, data) 
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
end


function mkDestroy()
	
	return {
		name="destroy",
		kind="destroy",
		
	}

end





bt.reset.bash_walls = function(node, data) 
	
end

bt.tick.bash_walls = function(node, data) 

	local pos = minetest.find_node_near(data.pos, 2, {"default:wood"})
	if pos == nil then
		return "failed"
	end
		
	minetest.set_node(pos, {name="air"})
	
	return "success"
end


function mkBashWalls()
	
	return {
		name="destroy",
		kind="bash_walls",
		
	}

end














