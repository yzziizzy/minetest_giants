-- Mobs Api (16th January 2016)

function mob_goTo(self, pos)
	
	
	
	
	
end




-- register mob function
function mobs:register_simple_mob(name, def)
--[[
	local btdata = {
		waypoints= {},
		counters={},
		inv=minetest.create_detached_inventory("main", {}),
		
		history={},
		history_queue={},
		history_depth=20,
	}
	
 	btdata.inv:set_size("main", 9)]]
	
minetest.register_entity(name, {

	stepheight = def.stepheight or 0.6,
	name = name,
	type = def.type,
	attack_type = def.attack_type,
	fly = def.fly,
	fly_in = def.fly_in or "air",
	owner = def.owner or "",
	order = def.order or "",
	on_die = def.on_die,
	do_custom = def.do_custom,
	jump_height = def.jump_height or 6,
	jump_chance = def.jump_chance or 0,
	drawtype = def.drawtype, -- DEPRECATED, use rotate instead
	rotate = math.rad(def.rotate or 0), --  0=front, 90=side, 180=back, 270=side2
	lifetimer = def.lifetimer or 180, -- 3 minutes
	hp_min = def.hp_min or 5,
	hp_max = def.hp_max or 10,
	physical = true,
	collisionbox = def.collisionbox,
	visual = def.visual,
	visual_size = def.visual_size or {x = 1, y = 1},
	mesh = def.mesh,
	makes_footstep_sound = def.makes_footstep_sound or false,
	view_range = def.view_range or 5,
	walk_velocity = def.walk_velocity or 1,
	run_velocity = def.run_velocity or 2,
	damage = def.damage or 0,
	light_damage = def.light_damage or 0,
	water_damage = def.water_damage or 0,
	lava_damage = def.lava_damage or 0,
	fall_damage = def.fall_damage or 1,
	fall_speed = def.fall_speed or -10, -- must be lower than -2 (default: -10)
	drops = def.drops or {},
	armor = def.armor,
	on_rightclick = def.on_rightclick,
	arrow = def.arrow,
	shoot_interval = def.shoot_interval,
	sounds = def.sounds or {},
	animation = def.animation,
	follow = def.follow,
	jump = def.jump or true,
	walk_chance = def.walk_chance or 50,
	attacks_monsters = def.attacks_monsters or false,
	group_attack = def.group_attack or false,
	--fov = def.fov or 120,
	passive = def.passive or false,
	recovery_time = def.recovery_time or 0.5,
	knock_back = def.knock_back or 3,
	blood_amount = def.blood_amount or 5,
	blood_texture = def.blood_texture or "mobs_blood.png",
	shoot_offset = def.shoot_offset or 0,
	floats = def.floats or 1, -- floats in water by default
	replace_rate = def.replace_rate,
	replace_what = def.replace_what,
	replace_with = def.replace_with,
	replace_offset = def.replace_offset or 0,
	timer = 0,
	env_damage_timer = 0, -- only used when state = "attack"
	tamed = false,
	pause_timer = 0,
	horny = false,
	hornytimer = 0,
	child = false,
	gotten = false,
	health = 0,
	reach = def.reach or 3,
	htimer = 0,
	child_texture = def.child_texture,
	docile_by_day = def.docile_by_day or false,
	time_of_day = 0.5,
	fear_height = def.fear_height or 0,
	runaway = def.runaway,
	runaway_timer = 0,
	destination = nil,
	
	bt_timer = 0,
	old_y = 0, -- some sort of weird bug
	
	goTo = mob_goTo,

	bt = nil,
	btData = nil,

	on_step = function(self, dtime)
		local btdata = self.btData
	
		local pos = self.object:getpos()
		local yaw = self.object:getyaw() or 0
	
		btdata.pos = pos
		btdata.yaw = yaw
		btdata.mob = self
		--btdata.inv = self.object:get_inventory()
		--btdata.inv:set_size("main", 9)
		--btdata.inv:add_item("main", "default:tree 50")
		
		self.bt_timer = self.bt_timer + dtime
		--print("bt_timer "..self.bt_timer)
		
		if self.bt_timer > 2 then
		
			print("\n<<< start >>>")
			
			-- inventories cannot be serialized and cause the game to crash if
			-- placed in the entity's table
			local inv = minetest.get_inventory({type="detached", name=self.inv_id})
			btdata.inv = inv
			
			bt.tick(self.bt, btdata)
			print("<<< end >>>\n")
			
			-- so clear it out after running the behavior trees
			btdata.inv = nil
			-- the inventory exists on its own
		
			self.bt_timer = 0
		end
		
		--self.object:set_inventory(btdata.inv)
		btdata.lastpos = pos
		

		if not self.fly then

			-- floating in water (or falling)
			local v = self.object:getvelocity()

			-- going up then apply gravity
			if v.y > 0.1 then

				self.object:setacceleration({
					x = 0,
					y = self.fall_speed,
					z = 0
				})
			end

			-- in water then float up
			if minetest.registered_nodes[node_ok(pos).name].groups.water then

				if self.floats == 1 then

					self.object:setacceleration({
						x = 0,
						y = -self.fall_speed / (math.max(1, v.y) ^ 2),
						z = 0
					})
				end
			else
				-- fall downwards
				self.object:setacceleration({
					x = 0,
					y = self.fall_speed,
					z = 0
				})

				-- fall damage
				if self.fall_damage == 1
				and self.object:getvelocity().y == 0 then

					local d = self.old_y - self.object:getpos().y

					if d > 5 then

						self.object:set_hp(self.object:get_hp() - math.floor(d - 5))

						effect(pos, 5, "tnt_smoke.png")

						if check_for_death(self) then
							return
						end
					end

					self.old_y = self.object:getpos().y
				end
			end
		end

-- 		-- knockback timer
-- 		if self.pause_timer > 0 then
-- 
-- 			self.pause_timer = self.pause_timer - dtime
-- 
-- 			if self.pause_timer < 1 then
-- 				self.pause_timer = 0
-- 			end
-- 
-- 			return
-- 		end

		-- attack timer
-- 		self.timer = self.timer + dtime

-- 		if self.state ~= "attack" then
-- 
-- 			if self.timer < 1 then
-- 				return
-- 			end
-- 
-- 			self.timer = 0
-- 		end

		-- never go over 100
		if self.timer > 100 then
			self.timer = 1
		end

		-- node replace check (cow eats grass etc.)
		replace(self, pos)

		-- mob plays random sound at times
		if self.sounds.random
		and math.random(1, 100) == 1 then

			minetest.sound_play(self.sounds.random, {
				object = self.object,
				max_hear_distance = self.sounds.distance
			})
		end

		-- environmental damage timer (every 1 second)
		self.env_damage_timer = self.env_damage_timer + dtime

		if (self.state == "attack" and self.env_damage_timer > 1)
		or self.state ~= "attack" then

			self.env_damage_timer = 0

			do_env_damage(self)

			-- custom function (defined in mob lua file)
			if self.do_custom then
				self.do_custom(self)
			end
		end
		
		
		if self.destination ~= nil then
			
			--print("destination ")
			
			local dist = distance(pos, self.destination)
			-- print("walk dist ".. dist)
			local s = self.destination
			local vec = {
				x = pos.x - s.x,
				y = pos.y - s.y,
				z = pos.z - s.z
			}
			
			-- tprint(vec)
			
			if vec.x ~= 0
			or vec.z ~= 0 then

				yaw = (math.atan(vec.z / vec.x) + math.pi / 2) - self.rotate
				
				if s.x > pos.x then
					yaw = yaw + math.pi
				end
				
				-- print("yaw " .. yaw)

				self.object:setyaw(yaw)
			end

			-- anyone but standing npc's can move along
			if dist > (self.approachDistance or .1) then

				if (self.jump
				and get_velocity(self) <= 0.5
				and self.object:getvelocity().y == 0)
				or (self.object:getvelocity().y == 0
				and self.jump_chance > 0) then
					do_jump(self)
				end
				
				
				
				set_velocity(self, self.walk_velocity)
				set_animation(self, "walk")
			else
				-- we have arrived
				self.destination = nil
				
				set_velocity(self, 0)
				set_animation(self, "stand")
			end
				
		end
		


	end,

	on_punch = function(self, hitter, tflp, tool_capabilities, dir)

		-- weapon wear
		local weapon = hitter:get_wielded_item()
		local punch_interval = 1.4

		if tool_capabilities then
			punch_interval = tool_capabilities.full_punch_interval or 1.4
		end

		if weapon:get_definition()
		and weapon:get_definition().tool_capabilities then

			weapon:add_wear(math.floor((punch_interval / 75) * 9000))
			hitter:set_wielded_item(weapon)
		end

		-- weapon sounds
		if weapon:get_definition().sounds ~= nil then

			local s = math.random(0, #weapon:get_definition().sounds)

			minetest.sound_play(weapon:get_definition().sounds[s], {
				object = hitter,
				max_hear_distance = 8
			})
		else
			minetest.sound_play("default_punch", {
				object = hitter,
				max_hear_distance = 5
			})
		end

		-- exit here if dead
		if check_for_death(self) then
			return
		end

		-- blood_particles
		if self.blood_amount > 0
		and not disable_blood then

			local pos = self.object:getpos()

			pos.y = pos.y + (-self.collisionbox[2] + self.collisionbox[5]) / 2

			effect(pos, self.blood_amount, self.blood_texture)
		end

		-- knock back effect
		if self.knock_back > 0 then

			local v = self.object:getvelocity()
			local r = 1.4 - math.min(punch_interval, 1.4)
			local kb = r * 5

			self.object:setvelocity({
				x = (dir.x or 0) * kb,
				y = 2,
				z = (dir.z or 0) * kb
			})

			self.pause_timer = r
		end

	
	end,

	on_activate = function(self, staticdata, dtime_s)
		self.btData = {
			groupID = "default",
			
			waypoints= {},
			counters={},
			
			history={},
			history_queue={},
			history_depth=20,
			
			posStack={},
		}
		
		local btdata = self.btData
		
		self.inv_id= name..":"..math.random(1, 2000000000)
		--print(btdata.id)
		
		btdata.lastpos = self.object:getpos()
	
		if type(def.pre_activate) == "function" then
			def.pre_activate(self, static_data, dtime_s)
		end
	
		-- load entity variables
		if staticdata then

			local tmp = minetest.deserialize(staticdata)

			if tmp then

				for _,stat in pairs(tmp) do
					self[_] = stat
				end
			end
		else
			self.object:remove()

			return
		end

		local inventory = minetest.create_detached_inventory(self.inv_id, {})
		inventory:set_size("main", 9)

		
		-- select random texture, set model and size
		if not self.base_texture then

			self.base_texture = def.textures[math.random(1, #def.textures)]
			self.base_mesh = def.mesh
			self.base_size = self.visual_size
			self.base_colbox = self.collisionbox
		end

		-- set texture, model and size
		local textures = self.base_texture
		local mesh = self.base_mesh
		local vis_size = self.base_size
		local colbox = self.base_colbox

		-- specific texture if gotten
		if self.gotten == true
		and def.gotten_texture then
			textures = def.gotten_texture
		end

		-- specific mesh if gotten
		if self.gotten == true
		and def.gotten_mesh then
			mesh = def.gotten_mesh
		end

		-- set child objects to half size
		if self.child == true then

			vis_size = {
				x = self.base_size.x / 2,
				y = self.base_size.y / 2
			}

			if def.child_texture then
				textures = def.child_texture[1]
			end

			colbox = {
				self.base_colbox[1] / 2,
				self.base_colbox[2] / 2,
				self.base_colbox[3] / 2,
				self.base_colbox[4] / 2,
				self.base_colbox[5] / 2,
				self.base_colbox[6] / 2
			}
		end

		if self.health == 0 then
			self.health = math.random (self.hp_min, self.hp_max)
		end

		self.object:set_hp(self.health)
		self.object:set_armor_groups({fleshy = self.armor})
		self.old_y = self.object:getpos().y
		self.object:setyaw(math.random(1, 360) / 180 * math.pi)
		self.sounds.distance = (self.sounds.distance or 10)
		self.textures = textures
		self.mesh = mesh
		self.collisionbox = colbox
		self.visual_size = vis_size

		-- set anything changed above
		self.object:set_properties(self)
		update_tag(self)
		
		if type(def.post_activate) == "function" then
			def.post_activate(self, static_data, dtime_s)
		end
	end,

	get_staticdata = function(self)

		-- remove mob when out of range unless tamed
		if mobs.remove
		and self.remove_ok
		and not self.tamed then

			--print ("REMOVED", self.remove_ok, self.name)

			self.object:remove()

			return nil
		end

		self.remove_ok = true
		self.attack = nil
		self.following = nil
		self.state = "stand"
		
		if self.btData ~= nil then
			self.btData.inv = nil -- just in case
			self.btData.mob = nil -- just in case
		end
		
		-- used to rotate older mobs
		if self.drawtype
		and self.drawtype == "side" then
			self.rotate = math.rad(90)
		end

		local tmp = {}

		for _,stat in pairs(self) do

			local t = type(stat)

			if  t ~= 'function'
			and t ~= 'nil'
			and t ~= 'userdata' then
				tmp[_] = self[_]
			end
		end

		-- print('===== '..self.name..'\n'.. dump(tmp)..'\n=====\n')
		return minetest.serialize(tmp)
	end,

})

end -- END mobs:register_mob function




-- set content id's
local c_air = minetest.get_content_id("air")
local c_ignore = minetest.get_content_id("ignore")
local c_obsidian = minetest.get_content_id("default:obsidian")
local c_brick = minetest.get_content_id("default:obsidianbrick")
local c_chest = minetest.get_content_id("default:chest_locked")


