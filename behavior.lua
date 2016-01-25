
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
dofile(path..'/behaviors/search.lua')
dofile(path..'/behaviors/movement.lua')
dofile(path..'/behaviors/actions.lua')





--[[
ideas:
	RobChest(items, max) // robs nearby chests of given items
	ThrowAt(projectile, target)
	FleeFrom(pos, distance)
	FleeFromNodes(nodes, distance) -- gets distance away from any nodes
	FleeFromPlayer(entity, distance)
	Stomp(pos) -- plays stomping animation and eventually destroys node
	Attack(entity) -- seek and kill entity
	FindNearbyEntity(entity_type)
	HealthBelow(n)
	HealthAbove(n)
		^ for heat, humidity, light, hunger, breath
	TossNearbyEntity() -- tosses a nearby entity
	SetTimer/IsExpired/HasPassed(name, [number])
	ChestHasItems(items)

stack nodes to make stairs when pathfinding is broken
travel up ladders and through doors

buildToHeight
put state/animation/model in the node, check and update in bt.tick/reset
findFlatArea
climbLadder
isChest full/empty
findnonfullchest
*findAvailableChest
craftItem

is target further/closer than x

 search for vertical stacks of x height
try to stack nodes to x height
forceload block
biomes
node level
line of sight
eat
drop/collect nearby items
rotate node
set time of day
jump/crouch
change top-level tree
try approach should fail if the node is directly above
build ladder to
drop items from inv
get surface node near
get node(a) x distance away from any other node(b) 
get random node in area
is the entity inv full
add/remove node to visited list

try approach, with a bt kid that's called when progress slows 

]]