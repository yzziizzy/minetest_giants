

local forager = function() 
	return bt.Sequence("", {
		bt.Succeed(bt.FindGroupCampfire()),
		
-- 		bt.Invert(bt.UntilFailed(bt.Sequence("find apples", {
-- 			bt.FindItemNear("default:apple", 20),
-- 			bt.Approach(2),
-- 			bt.PickUpNearbyItems("default:apple", 2.5),
-- 			bt.WaitTicks(1),
-- 		}))),

		bt.Invert(bt.UntilFailed(bt.Sequence("find saplings", {
			bt.FindItemNear("group:sapling", 20),
			bt.Approach(2),
			bt.PickUpNearbyItems("group:sapling", 2.5),
			bt.WaitTicks(1),
		}))),
		
		bt.GetGroupWaypoint("food_chest"),
		bt.Approach(2),
		bt.PutInChest(nil),
		
		bt.WaitTicks(1),
	})
end

local lumberjack = function() 
	return bt.Sequence("", {
		bt.Succeed(bt.FindGroupCampfire()),
		
		-- build a chest and remember where it is
		--bt.FindSpotOnGround(),
		--bt.SetNode({name="default:chest"}),
		bt.GetGroupWaypoint("lumber_chest"),
		bt.SetWaypoint("chest"),
		
		bt.UntilFailed(bt.Sequence("logs some trees", {
			
			-- find a tree
			bt.Selector("find a tree", {
				bt.Sequence("find a tree near the last one", {
					bt.GetWaypoint("tree"),
					bt.FindNodeNear({"group:tree"}, 15),
				}),
				bt.FindNodeNear({"group:tree"}, 50),
			}),
			bt.Approach(2),
			
			-- chop it down
			bt.Invert(bt.UntilFailed(bt.Sequence("chop tree", {
				bt.Wield("default:axe_steel"),
				bt.Animate("punch"),
				bt.FindNodeNear({"group:tree"}, 3),
				bt.DigNode(),
				bt.WaitTicks(1),
			}))),
			bt.SetWaypointHere("tree"),

			bt.Wield(""),

			
			bt.Succeed(bt.Sequence("pick up saplings", {
				--bt.FindItemNear("group:sapling", 20),
				bt.PickUpNearbyItems("group:sapling", 5),
			})),
			
			
			-- put wood in chest
			bt.GetGroupWaypoint("lumber_chest"),
			bt.Approach(2),
			bt.PutInChest(nil),
			
                                  
			bt.WaitTicks(1),
			bt.Print("end of loop \n"),
		}))
	})
end


local dig_region = function(item)
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

local dig_hole = function(item) 
	return bt.Sequence("", {
		bt.Succeed(bt.FindGroupCampfire()),
		
		-- find a place for a hole
		bt.FindSpotOnGround(),
		bt.SetWaypoint("hole"),
		bt.FindRegionAround(4),
		
		dig_region(item),
		
		bt.ScaleRegion({x=-1, y=0, z=-1}),
		bt.MoveRegion({x=0, y=-1, z=0}),
		dig_region(item),

		bt.ScaleRegion({x=-1, y=0, z=-1}),
		bt.MoveRegion({x=0, y=-1, z=0}),
		dig_region(item),
		
		bt.Die(),
	})
end


local fill_region = function(item)
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

local fence_region = function(item)
	return bt.Sequence("", {

		bt.Invert(bt.UntilFailed(bt.Sequence("fill region", {
			
			bt.FindPerimeterNodeInRegion({"air"}),
			bt.Approach(2),
			
			-- chop it down
			bt.Invert(bt.UntilFailed(bt.Sequence("fill region", {
				bt.FindPerimeterNodeInRegion({"air"}),
				bt.Approach(3),
				bt.Animate("punch"),
				bt.SetNode(item);
				bt.WaitTicks(1),
			}))),
			
			bt.Print("end of loop"),
		})))
	})
end

local build_house = function(item) 
	return bt.Sequence("", {
		bt.Succeed(bt.FindGroupCampfire()),
	
		-- find a place for a hole
		bt.FindSpotOnGround(),
		bt.SetWaypoint("house"),
		bt.FindRegionAround(3),
		
		bt.MoveRegion({x=0, y=1, z=0}),
		fill_region({name="default:cobble"}),
		
		bt.MoveRegion({x=0, y=1, z=0}),
		fence_region({name="default:tree"}),

		bt.MoveRegion({x=0, y=1, z=0}),
		fence_region({name="default:tree"}),
		
		bt.ScaleRegion({x=-1, y=0, z=-1}),
		bt.MoveRegion({x=0, y=1, z=0}),
		fill_region({name="default:wood"}),

		bt.ScaleRegion({x=-1, y=0, z=-1}),
		bt.MoveRegion({x=0, y=1, z=0}),
		fill_region({name="default:wood"}),
		
		bt.Die(),
	})
end





local build_campfire = function() 
	return bt.Sequence("build campfire", {
		bt.FindSpotOnGround(),
		bt.SetWaypoint("campfire"),

-- 		bt.FindRegionAround(2),
-- 		dig_region({"group:soil", "group:plant", "group:sand"}),
-- 		fill_region({name="default:gravel"}),

		bt.GetWaypoint("campfire"),
		bt.MoveTarget({x=0, y=-1, z=0}),

		bt.Animate("punch"),
	
		bt.DigNode(),
		bt.SetNode({name="default:coalblock"}),
		bt.WaitTicks(1),
	
		bt.MoveTarget({x=1, y=1, z=0}),
		bt.SetNode({name="stairs:slab_cobble"}),
		bt.WaitTicks(1),
		
		bt.MoveTarget({x=-1, y=0, z=1}),
		bt.SetNode({name="stairs:slab_cobble"}),
		bt.WaitTicks(1),
		
		bt.MoveTarget({x=-1, y=0, z=-1}),
		bt.SetNode({name="stairs:slab_cobble"}),
		bt.WaitTicks(1),
		
		bt.MoveTarget({x=1, y=0, z=-1}),
		bt.SetNode({name="stairs:slab_cobble"}),
		bt.WaitTicks(1),
		
		bt.MoveTarget({x=0, y=0, z=1}),
		bt.SetNode({name="giants:campfire"}),
		
		bt.FindGroupCampfire(),
		bt.SetRole("founder"),
	})

end


local spawn_at_campfire = function(role)
	return bt.Sequence("spawn at campfire", {
		bt.PushTarget(),
		bt.GetGroupWaypoint("spawnpoint"),
		bt.MoveTargetRandom({x=1, y=0, z=1}),
		bt.Spawn(role),
		bt.PopTarget(),
	})
end


local found_village = function() 
	return bt.Sequence("founding village", {
		build_campfire(),
		
		bt.MoveTarget({x=2, y=0, z=2}),
		bt.SetGroupWaypoint("spawnpoint"),
		
		bt.MoveTarget({x=-5, y=0, z=1}),
		bt.SetGroupWaypoint("lumber_chest"),
		bt.SetNode({name="default:chest"}),
		
		bt.MoveTarget({x=0, y=0, z=-6}),
		bt.SetGroupWaypoint("stone_chest"),
		bt.SetNode({name="default:chest"}),
		
		bt.MoveTarget({x=6, y=0, z=6}),
		bt.SetGroupWaypoint("food_chest"),
		bt.SetNode({name="default:chest"}),
		
		bt.WaitTicks(1),
		spawn_at_campfire("lumberjack"),
		
		bt.WaitTicks(2),
		spawn_at_campfire("lumberjack"),
		
		--build_house(),
				
		bt.Die(),
	})
end





local quarry = function(item) 
	return bt.Sequence("", {
		bt.Succeed(bt.FindGroupCampfire()),
	
		-- build a chest and remember where it is
		bt.FindSpotOnGround(),
		bt.SetNode({name="default:chest"}),
		bt.SetWaypoint("chest"),
		
		bt.UntilFailed(bt.Sequence("dig some dirt", {
			
			-- find a tree
			bt.Selector("find a tree", {
				bt.Sequence("find a tree near the last one", {
					bt.GetWaypoint("tree"),
					bt.FindNodeNear(item, 15),
				}),
				bt.FindNodeNear(item, 50),
			}),
			bt.Approach(2),
			
			-- chop it down
			bt.Counter("foo", "set", 0),
			bt.Invert(bt.UntilFailed(bt.Sequence("chop tree", {
				bt.Animate("punch"),
				bt.FindNodeNear(item, 2),
				bt.DigNode(),
				bt.WaitTicks(1),
				bt.Counter("foo", "inc"),
				bt.Invert(bt.Counter("foo", "eq", 3)),
			}))),
			bt.SetWaypointHere("tree"),
			
			
			-- put wood in chest
			bt.GetWaypoint("chest"),
			bt.Approach(2),
			bt.PutInChest(nil),
			
			bt.WaitTicks(1),
			
			bt.Print("end of loop"),
		}))
	})
end


local burn_shit = function(what) 
	return bt.Sequence("", {
		-- build a chest and remember where it is
		bt.FindNewNodeNear(what, 50),
		bt.Approach(10),
		bt.SetWaypointHere("safe"),
		
		bt.Approach(2),
		bt.SetFire(),
		
		bt.GetWaypoint("safe"),
		bt.Approach(.1)
		
	})
end

local blow_shit_up = function(what) 
	return bt.Sequence("", {
		-- build a chest and remember where it is
		bt.FindNewNodeNear(what, 50),
		bt.Approach(10),
		bt.SetWaypointHere("safe"),
		
		bt.Approach(2),
		bt.FindNodeNear("air", 1),
		bt.SetNode({name="tnt:tnt"}),
		bt.Punch("default:torch"), -- broken
		
		bt.GetWaypoint("safe"),
		bt.Approach(.1),
		bt.WaitTicks(3),
		
	})
end


local build_walls = function(what) 
	return bt.Sequence("", {
		-- build a chest and remember where it is
		
		bt.FindNewNodeNear(what, 50),
		
		bt.Approach(10),
		bt.SetWaypointHere("center"),
		
		bt.Approach(2),
		bt.SetFire(),
		
		bt.GetWaypoint("safe"),
		bt.Approach(.1)
		
	})
end


local make_giant = function(name, behavior_fn) 

	mobs:register_simple_mob("giants:giant_"..name, {
		type = "monster",
		passive = false,
		attack_type = "dogfight",
		reach = 2,
		damage = 1,
		hp_min = 4,
		hp_max = 20,
		armor = 100,
		collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
		visual = "mesh",
		mesh = "character.b3d",
		drawtype = "front",
		textures = {
			{"mobs_npc.png"},
		},
		makes_footstep_sound = true,
		walk_velocity = 1.5,
		run_velocity = 4,
		view_range = 15,
		jump = true,
		floats = 0,
		drops = {
			{name = "default:iron_lump",
			chance = 1, min = 3, max = 5},
		},
		water_damage = 0,
		lava_damage = 4,
		light_damage = 0,
		fear_height = 3,
		animation = {
			speed_normal = 30,
			speed_run = 30,
			stand_start = 0,
			stand_end = 79,
			walk_start = 168,
			walk_end = 187,
			run_start = 168,
			run_end = 187,
			punch_start = 200,
			punch_end = 219,
		},
		
		pre_activate = function(self, s,d)
			self.bt = bt.Repeat("root", nil, {
				--burn_shit({"doors:door_wood_b_1", "doors:door_wood_t_1", "doors:door_wood_b_2", "doors:door_wood_t_2"})
	-- 			blow_shit_up({"doors:door_steel_b_1", "doors:door_steel_t_1", "doors:door_steel_b_2", "doors:door_steel_t_2"})
				--quarry({"default:dirt"})
				--build_walls({"default:dirt"})
				behavior_fn();
			})
			
		end
	})
	
	mobs:register_egg("giants:giant_"..name, "Giant ("..name..")", "default_desert_sand.png", 1)
end

make_giant("quarry", function() 
	return quarry({"default:sand"})
end)

make_giant("lumberjack", function() 
	return lumberjack()
end)

make_giant("digger", function() 
	return dig_hole({"default:dirt", "default:dirt_with_grass", "default:sand", "default:stone"})
end)

make_giant("builder", function() 
	return build_house()
end)

make_giant("founder", function() 
	return found_village()
end)

make_giant("forager", function() 
	return forager()
end)

--[[
		self.bt = bt.Repeat("root", nil, {
			bt.Sequence("snuff torches", {
				bt.FindNewNodeNear({"default:torch"}, 20, 4),
				bt.Selector("seek", {
					bt.TryApproach(1.8),
					bt.BashWalls(),
				}),
-- 				bt.Destroy(),
-- 				bt.SetFire(),
			})
		})


]]
--mobs:register_spawn("giants:giant", {"default:desert_sand"}, 20, 0, 7000, 2, 31000)

--mobs:register_egg("giants:giant", "Giant", "default_desert_sand.png", 1)
