extends Fighter

var color_set = false
var AIC = null
var emit_after_images = false
var images = 3
var image_lifetime = 0.5
var image_alpha = 1.0
var dragging: Array = []
var dolls: Array = []
var needle = null
var tethered = null
var pulling = false
var was_pulling = false
var no_pull = false
var active_minion = 0
var minion_attack = 0
var pred_tethered_minion = null
var snap = 0
var snap_x = 0
var snap_y = 0
var lights_on = false
var light_box = true
var light_pos = {"x1":0, "y1":0}
var LightDropCD = 0
var pushblocked = false
var pinsCD = 0

const PULL_SPEED = "3"
const MAX_PULL_SPEED = "13"
const MAX_PULL_UPWARD_SPEED = "-9"
const BACKWARD_PULL_PENALTY = 2

onready var pull_string = $"%Pull_String"
onready var tether = $"%Tether_String"
onready var light_bounds = $"%LightBox"
onready var light1 = $"%LightBeam"

const FLUFF1 = preload("res://Tin_Rye_Alonso/characters/Alonso/particles/fluff1.tscn")
const FLUFF2 = preload("res://Tin_Rye_Alonso/characters/Alonso/particles/fluff2.tscn")
const MINION = preload("res://Tin_Rye_Alonso/characters/Alonso/projectiles/Minion.tscn")
const MINION_DETONATE = preload("res://Tin_Rye_Alonso/characters/Alonso/projectiles/MinionDestruct.tscn")

func _ready():
	pass

func tick():
	.tick()
	if LightDropCD > 0:
		LightDropCD -= 1
	if pinsCD > 0:
		pinsCD -= 1
		
	if not color_set and !is_ghost:
		color_set = true
		if style_extra_color_1 and applied_style: 
			AIC = style_extra_color_1
			pull_string.default_color = style_extra_color_1
			tether.default_color = style_extra_color_1
		else: AIC = extra_color_1
	
	if emit_after_images: after_image(image_lifetime, image_alpha, images)
	
	if needle:
		if is_instance_valid(needle):
			if needle.disabled:
				needle = null
		else: needle = null
			
	if pulling and not hitlag_ticks:
		if no_pull:
			pulling = false
			tethered = null
		var target = obj_local_center(opponent)
		if tethered or needle:
			match tethered:
				"opp":
					pass
				"min0":
					if dolls[0]:
						target = obj_local_center(dolls[0])
					else: 
						tethered = null
						pulling = false
				"min1":
					if dolls[1]:
						target = obj_local_center(dolls[1])
					else: 
						tethered = null
						pulling = false
				"min2":
					if dolls[2]:
						target = obj_local_center(dolls[2])
					else: 
						tethered = null
						pulling = false
				_:
					target = obj_local_center(needle)
		else: 
			pulling = false
			tethered = null
			
		#print("Pull target - ",target)
		#print(fixed.vec_len(str(target.x), str(target.y)))
		if fixed.lt(fixed.vec_len(str(target.x), str(target.y)), "35"):
			pulling = false
			tethered = null
			if needle:
				needle.fizzle()
			
		if pulling:
			var dir = fixed.normalized_vec_times(str(target.x), str(target.y), PULL_SPEED)
			was_pulling = true
			
			apply_force(dir.x, dir.y)
			limit_speed(MAX_PULL_SPEED)
			var vel = get_vel()
			if fixed.lt(vel.y, MAX_PULL_UPWARD_SPEED):
				set_vel(vel.x, MAX_PULL_UPWARD_SPEED)
			if fixed.sign(dir.x) != get_opponent_dir() and combo_count <= 0:
				add_penalty(BACKWARD_PULL_PENALTY)
	if was_pulling and !pulling:
		was_pulling = false
		var vel = get_vel()
		set_vel(fixed.mul(vel.x, "0.4"), fixed.mul(vel.y, "0.4"))
			
			
	#summon check
	if dolls:
		for d in dolls: #clear invalid items in list
			if is_instance_valid(d):
				if d.disabled:
					dolls.erase(d)
			else: dolls.erase(d)
		while dolls.size() > 3: #detonate if over the limit
			var cur_doll = dolls[0]
			var pos = cur_doll.get_pos()
			var explode = cur_doll.spawn_object(MINION_DETONATE, 0, 0, true)
			var vel = cur_doll.get_vel()
			explode.set_grounded(false)
			explode.set_vel(vel.x, vel.y)
			explode.set_facing(cur_doll.get_facing_int())
			apply_projectile_style(explode)
			dolls.erase(cur_doll)
			cur_doll.true_disable()
			
		#check dolls against hitboxes
		if not hitlag_ticks:
			for hitbox in get_active_hitboxes():
				#print(hitbox.hitbox_type)
				if !hitbox.hitbox_type == 0:
					continue
				for d in dolls:
					if !(d.name in hitbox.hit_objects):
						if hitbox.overlaps(d.hurtbox):
							var saved_hitlag = hitbox.hitlag_ticks
							var saved_victim_hitlag = hitbox.victim_hitlag
							var saved_knockback = hitbox.knockback
							hitbox.hitlag_ticks = 3
							hitbox.victim_hitlag = 0
							hitbox.knockback = fixed.add(hitbox.knockback, "4")
							d.hit_by_owner = true
							hitbox.hit(d)
							hitbox.hitlag_ticks = saved_hitlag
							hitbox.victim_hitlag = saved_victim_hitlag
							hitbox.knockback = saved_knockback
	
	#drag script for attacks
	if dragging:
		#print(dragging)
		var selfpos = get_pos()
		for obj in dragging:
			#if obj not in hurt state, release it
			if obj.current_state().busy_interrupt_type != CharacterState.BusyInterrupt.Hurt:
				dragging.erase(obj)
			#print(obj)
			elif obj is Fighter:
				var moved = false
				var pos = obj.get_pos()
				#print ("X diff: ",selfpos.x-pos.x,", Y diff: ",selfpos.y-pos.y)
				if selfpos.x - pos.x + (snap_x*get_facing_int()) > snap:
					#print("Moved From x: ",selfpos.x-pos.x, ", ", selfpos.y - pos.y)
					pos.x = selfpos.x - snap + (snap_x*get_facing_int())
					moved = true
				elif selfpos.x - pos.x + (snap_x*get_facing_int()) < -snap:
					#print("Moved From x: ",selfpos.x-pos.x, ", ", selfpos.y - pos.y)
					pos.x = selfpos.x + snap + (snap_x*get_facing_int())
					moved = true
				if selfpos.y - pos.y + snap_y > snap:
					#print("Moved From y: ",selfpos.y-pos.y)
					pos.y = selfpos.y - snap + snap_y
					moved = true
				elif selfpos.y - pos.y + snap_y < -snap:
					#print("Moved From y: ",selfpos.y-pos.y)
					pos.y = selfpos.y + snap + snap_y
					moved = true
				if moved:
					#print("Moved To: ",selfpos.x-pos.x,", ",selfpos.y-pos.y)
					#print("Moved To: ",pos.x,", ",pos.y)
					obj.set_pos(pos.x, pos.y)
	if !is_ghost:
		if lights_on:
			if light1.default_color.a <= 0.5: light1.default_color.a += 0.05
		else:
			if light1.default_color.a > 0: light1.default_color.a -= 0.05


func on_state_started(state):
	.on_state_started(state)
	pushblocked = false
	#if state.name in ["ParrySuper", "ParryHigh", "ParryAfterWhiff", "ParryAuto", "ParryLow", "ParryAir", "Roll"]:
		#pass
	if state.is_hurt_state:
		pulling = false
		tethered = null
		if needle: needle.force_return = true
		
func on_got_push_blocked():
	pushblocked = true
	
func apply_forces():
	if pulling:
		apply_forces_no_limit()
	else :
		.apply_forces()

func _draw():
	._draw()
	if tethered:
		pred_tethered_minion = tethered
		var pos = Vector2(0, 0)
		match tethered:
			"opp":
				tether.visible = true
				pos = opponent.get_hurtbox_center()
			"min0":
				if dolls[0]:
					pos = dolls[0].get_hurtbox_center()
					tether.visible = true
				else: 
					tethered = null
					tether.visible = false
			"min1":
				if dolls[1]:
					pos = dolls[1].get_hurtbox_center()
					tether.visible = true
				else: 
					tethered = null
					tether.visible = false
			"min2":
				if dolls[2]:
					pos = dolls[2].get_hurtbox_center()
					tether.visible = true
				else: 
					tethered = null
					tether.visible = false
		tether.points[1] = to_local(Vector2(pos.x, pos.y))
	elif needle:
		if is_instance_valid(needle):
			tether.visible = true
			var pos = needle.get_pos()
			tether.points[1] = to_local(Vector2(pos.x, pos.y))
	else: tether.visible = false
	
	if is_ghost:
		var count = 0
		#print("Ghost dolls - ", dolls)
		for d in dolls:
			#print("# ", d)
			if active_minion <= dolls.size() - 1:
				d.marker_ghost.visible = (d == dolls[active_minion])
	
	if !is_ghost:
		if light_box:
			light_bounds.visible = true
			var pos = get_pos()
			light_bounds.margin_top = -350 - pos.y
			light_bounds.margin_bottom = -pos.y
			light_bounds.margin_left = -stage_width - pos.x
			light_bounds.margin_right = stage_width - pos.x
			light1.points[1].x = pos.x +stage_width -(10 * get_facing_int())
			
			if !lights_on:
				if light1.default_color.a <= 0 and light1.default_color.a <= 0:
					light_box = false
					light_bounds.visible = false

func on_got_parried():
	.on_got_parried()
	print("Alonso got parried")
	if dolls:
		for d in dolls: #clear invalid items in list
			if is_instance_valid(d):
				if d.disabled:
					dolls.erase(d)
			else: dolls.erase(d)
		#check doll is in launched state, and cancel to hurt state
		for d in dolls:
			#print(d.current_state().name)
			if d.current_state().name == "Launched":
				d.hit_by_owner = false
				if d.is_grounded(): d.change_state("HurtGrounded")
				else: d.change_state("HurtAerial")

func process_extra(extra):
	.process_extra(extra)
	#if extra["commanding_minion"]:
	active_minion = extra["commanding_minion"]
	minion_attack = extra["minion_attack"]
	#print("Extra sent minion ID - ",active_minion)'
	#if extra.has("pull"):
	if pulling and !extra.pull:
		pulling = false
		tethered = null
		if needle: needle.force_return = true
	if !pulling and extra.pull:
		pulling = true
		play_sound("reel")
	else: pulling = extra.pull

func apply_projectile_style(obj):
	obj.applied_style = applied_style
	obj.set_material(sprite.get_material())
	obj.sprite.set_material(sprite.get_material())
	if "AIC" in obj: obj.AIC = AIC

func after_image(lifetime = 0.2, alpha = 0.5, images = -1, color:Color = AIC, texture = null):
	if is_ghost or ReplayManager.resimulating:
		return 
	color.a = alpha
	call_deferred("_create_speed_after_image", color, lifetime, images, texture)
	
func _create_speed_after_image(color:Color = Color.white, lifetime = 0.2, images = -1,  texture = null):
	var speed_image_effect = preload("res://Tin_Rye_Alonso/characters/Alonso/particles/AfterImageCustom.tscn")
	#var speed_image_effect = preload("res://fx/SpeedImageEffect.tscn")
	if not texture: texture = sprite.frames.get_frame(sprite.animation, sprite.frame)
	var effect = _spawn_particle_effect(speed_image_effect, get_pos_visual() + sprite.offset)
	effect.set_texture(texture)
	effect.lifetime = lifetime
	effect.images = images
	effect.set_color(color)
	effect.sprite.flip_h = get_facing_int() == - 1

func _spawn_particle_effect(particle_effect:PackedScene, pos:Vector2, dir = Vector2.RIGHT):
	var obj = particle_effect.instance()
	add_child(obj)
	#print("Particle Spawn - ",obj)

	if applied_style:
		if obj.name == "colored" and not is_ghost:
			#print(applied_style)
			#particle gets style coloring. Check children for color typing
			#print("Particle Style Activated")
			var color1 = extra_color_1
			if applied_style.has("extra_color_1"): color1 = applied_style.extra_color_1
			var color2 = extra_color_2
			if applied_style.has("extra_color_2"): color2 = applied_style.extra_color_2
			
			for C in obj.get_children():
				#print ("PARTICLE CHILDREN")
				#print(C.name)
				if "1color" in C.name:
					#print(C.color)
					C.color = color1
					#print(C.color)
				elif "gradient" in C.name:
					C.color_ramp.colors[0] = color1
				elif "light_fade" in C.name:
					var col1 = color1 #keep alpha value
					col1.a = C.color_ramp.colors[1].a
					C.color_ramp.colors[1] = col1
				elif "flicker" in C.name:
					C.color_ramp.colors[0] = color1
					C.color_ramp.colors[2] = color1
					C.color_ramp.colors[4] = color1
					var col1 = color1 #keep alpha value
					col1.a = C.color_ramp.colors[5].a
					C.color_ramp.colors[5] = col1
	obj.tick()
	var facing = - 1 if dir.x < 0 else 1
	obj.position = pos
	if facing < 0:
		obj.rotation = (dir * Vector2( - 1, - 1)).angle()
	else :
		obj.rotation = dir.angle()
	obj.scale.x = facing
	remove_child(obj)
	emit_signal("particle_effect_spawned", obj)
	return obj

func take_damage(damage:int, minimum = 0, meter_gain_modifier = "1.0", combo_scaling_offset = 0, damage_taken_meter_gain_modifier = "1.0"):
	if damage > 30:
		if damage < 80:
			spawn_particle_effect_relative(FLUFF1)
			var sound = randi_range(0,1)
			#print(sound)
			if sound: play_sound("squeak1")
			else: play_sound("squeak2")
		else:
			spawn_particle_effect_relative(FLUFF2)
			var sound = randi_range(0,2)
			if sound == 1: play_sound("squeak3")
			if sound == 2: play_sound("squeak4")
			else: play_sound("squeak2")
			
	.take_damage(damage, minimum, meter_gain_modifier, combo_scaling_offset, damage_taken_meter_gain_modifier)
