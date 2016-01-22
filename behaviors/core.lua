--[[ TODO:

call/clone
priority
loop times until success/fail

]]


bt.register_action("Sequence", {
	tick = function(node, data) 
		
		local ret
		
		if node.current_kid  == -1 then
			node.current_kid = 1
			ret = "success" -- trick reset into being run
		end
		
		while node.current_kid <= table.getn(node.kids) do
		
			local cn = node.kids[node.current_kid]
			
			-- reset fresh nodes
			if ret == "success" then
				bt.reset(cn, data)
			end
			
			-- tick the current node
			ret = bt.tick(cn, data)
			print(" sequence '"..node.name.."' got status ["..ret.."] from kid "..node.current_kid)
			if ret == "running" or ret == "failed" then
				return ret
			end
			
			node.current_kid = node.current_kid  + 1
		end
		
		return "success"
	end,
	
	reset = function(node, data)
		node.current_kid = -1
	end,
	
	ctor = function(name, list)
		return {
			name=name,
			current_kid=-1,
			kids=list,
		}
	end,
})



bt.register_action("Selector", {
	tick = function(node, data) 
		
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
				bt.reset(cn, data)
			end
			
			-- tick the current node
			ret = bt.tick(cn, data)
			print(" selector '"..node.name.."' got status ["..ret.."] from kid "..node.current_kid)
			if ret == "running" or ret == "success" then
				return ret
			end
			
			node.current_kid = node.current_kid  + 1
		end
			
		
		return "failed"
	end,
	
	reset = function(node, data)
		print("selector resetting")
		node.current_kid = -1
	end,
	
	ctor = function(name, list)
		return {
			name=name,
			current_kid=-1,
			kids=list,
		}
	end,
})



bt.register_action("Repeat", {
	tick = function(node, data)
		--tprint(node)
		if node.times ~= -1 then
			node.count = node.count + 1
			if node.count > node.times then
				return "success"
			end
		end

		local ret = bt.tick(node.kids[1], data)
		if ret ~= "running" then
			bt.reset(node.kids[1], data)
		end


		return "success"
	end,
	
	reset = function(node, data)
		node.count = 0
		if node.times_fn then
			node.times = node.times_fn()
		end
	end,
	
	--  -1 times is forever 
	ctor = function(name, times, what)
		
		local x = {
			name=name,
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
	end,
})
 


bt.register_action("Invert", {
	tick = function(node, data)
		local ret = bt.tick(node.kid, data)
		if ret == "running" then
			return "running"
		elseif ret == "success" then
			return "failed"
		else
			return "success"
		end
	end,
	
	reset = function(node, data)
		bt.reset(node.kid, data)
	end,
	
	ctor = function(kid)
		return {
			kid=kid,
		}
	end,
})





bt.register_action("Random", {
	tick = function(node, data)
		return bt.tick(node.kids[node.chosen_kid], data)
	end,
	
	reset = function(node, data)
		node.chosen_kid = (math.random() % table.getn(node.kids)) + 1
		bt.reset(node.kids[node.chosen_kid], data)
	end,
	
	ctor = function(kids)
		return {
			kid=kids,
			chosen_kid=nil,
		}
	end,
})


bt.register_action("UntilFailed", {
	tick = function(node, data)

		-- TODO: BUG: make sure it resets the kid the first run
		local ret
		while ret ~= "failed" do

			ret = bt.tick(node.kid, data)
			if ret == "running" then
				return "running"
			elseif ret == "success" then
				bt.reset(node.kid, data)
			end
		end

		return "failed"
	end,
	
	reset = function(node, data)
		bt.reset(node.kid, data)
	end,
	
	--  -1 times is forever 
	ctor = function(what)
		return {
			kid = what,
		}
	end,
})
 



bt.register_action("UntilSuccess", {
	tick = function(node, data)

		-- TODO: BUG: make sure it resets the kids the first run
		local ret
		while ret ~= "success" do

			ret = bt.tick(node.kid, data)
			if ret == "running" then
				return "running"
			elseif ret == "failed" then
				bt.reset(node.kid, data)
			end
		end

		return "success"
	end,
	
	reset = function(node, data)
		bt.reset(node.kid, data)
	end,
	
	--  -1 times is forever 
	ctor = function(what)
		return {
			kid = what,
		}
	end,
})
 

bt.register_action("WaitTicks", {
	tick = function(node, data)
		if node.current == nil then
			node.current = 0
		end
	
		node.current = node.current + 1
		
		if node.current > node.n then
			node.current = 0
			return "success"
		end
		
		return "running"
	end,
	
	reset = function(node, data)
		node.current = 0
	end,
	
	--  -1 times is forever 
	ctor = function(n)
		return {
			n=n,
			current=0,
		}
	end,
})
