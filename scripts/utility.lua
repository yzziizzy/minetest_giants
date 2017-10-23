
btu.place_at = function(item) 
	return bt.Sequence("", {
		bt.Approach(2),
		bt.Animate("punch"),
		bt.SetNode(item),
	})
end

btu.build_to = function(item) 
	return bt.Sequence("", {
	
	
		bt.Approach(2),
		bt.Animate("punch"),
		bt.SetNode(item),
	})
end


btu.wander_around = function() 
	return bt.Sequence("", {
		bt.RandomDirection(),
		bt.MoveInDirection(7),
		bt.Approach(2),
	})
end





-- designed for use in a selector
btu.forage_node = function(items, dist, counter, maxItems) 
	return bt.UntilFailed(bt.Sequence("forage "..dump(items), {
		bt.Invert(bt.Counter(counter, "gte", maxItems)),
		bt.FindNodeNear(items, dist),
		bt.Approach(2),
		bt.Animate("punch"),
		bt.DigNode(),
		bt.WaitTicks(1),
		bt.Counter(counter, "inc"),
	}))
end

btu.forage_item = function(items, dist, counter, maxItems) 
	return bt.UntilFailed(bt.Sequence("forage "..dump(items), {
		bt.Invert(bt.Counter(counter, "gte", maxItems)),
		bt.FindItemNear(item, dist),
		bt.Approach(2),
		bt.Animate("punch"),
		bt.PickUpNearbyItems(item, 2.5),
		bt.WaitTicks(1),
		bt.Counter(counter, "inc"),
	}))
end





btu.dig_region = function(item)
	return bt.Sequence("", {

		bt.Invert(bt.UntilFailed(bt.Sequence("dig the hole", {
			
			bt.FindNodeInRange(item),
			bt.Approach(2),
			
			-- chop it down
			bt.Invert(bt.UntilFailed(bt.Sequence("dig hole", {
				bt.FindNodeInRange(item),
				bt.Approach(3),
				bt.Animate("punch"),
				bt.DigNode(),
				bt.WaitTicks(1),
			}))),
			
			bt.Print("end of loop"),
		})))
	})
end

btu.dig_hole = function(item) 
	return bt.Sequence("", {
		bt.Succeed(bt.FindGroupCampfire()),
		
		-- find a place for a hole
		bt.FindSpotOnGround(),
		bt.SetWaypoint("hole"),
		bt.FindRegionAround(4),
		
		btu.dig_region(item),
		
		bt.ScaleRegion({x=-1, y=0, z=-1}),
		bt.MoveRegion({x=0, y=-1, z=0}),
		btu.dig_region(item),

		bt.ScaleRegion({x=-1, y=0, z=-1}),
		bt.MoveRegion({x=0, y=-1, z=0}),
		btu.dig_region(item),
		
		bt.Die(),
	})
end


btu.fill_region = function(item)
	return bt.Sequence("", {

		bt.Invert(bt.UntilFailed(bt.Sequence("fill region", {
			
			bt.FindNodeInRange({"air"}),
			bt.Approach(2),
			
			-- chop it down
			bt.Invert(bt.UntilFailed(bt.Sequence("fill region", {
				bt.FindNodeInRange({"air"}),
				bt.Approach(3),
				bt.Animate("punch"),
				bt.SetNode(item),
				bt.WaitTicks(1),
			}))),
			
			bt.Print("end of loop"),
		})))
	})
end
