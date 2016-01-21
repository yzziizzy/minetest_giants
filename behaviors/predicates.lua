 





bt.register_action("IsDaytime", {
	tick = function(node, data)
		local tod = minetest.get_timeofday() * 24000
		if tod > 6000 and tod < 18000 then
			return "success"
		end
		
		return "failed"
	end,
})







