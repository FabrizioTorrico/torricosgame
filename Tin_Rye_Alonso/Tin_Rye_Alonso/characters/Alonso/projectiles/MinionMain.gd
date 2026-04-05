extends BaseProjectile

var applied_style = null
var data_transfer = null
var command = null
var commandable = true
var drop_target = 0
var hit_stun = 0
var damage = 0
const HITPOINTS = 150
var hit_by_owner = false
var AIC = Color("b800ff")
var emit_after_images = false
var images = 3
var image_lifetime = 0.2
var image_alpha = 1.0
var color_set = false
var Alonso_Minion = true
var lights_on = false
var light_box = true
var light_pos = {"x1":0, "y1":0, "x2":0, "y2":0}
var hurt_recover = 0

onready var marker = $"%marker"
onready var marker_ghost = $"%marker_ghost"
onready var FX = $"%LaunchFX"
onready var Skid = $"%SkidFX"
onready var light_bounds = $"%LightBox"
onready var light1 = $"%LightBeam"
onready var light2 = $"%LightBeam2"

func init(pos = null):
	.init(pos)
	#creator.connect("on_got_hit", self, "_on_creator_got_hit")
	if not self in creator.dolls:
		creator.dolls.append(self)

func _draw():
	if !is_ghost:
		if light_box:
			light_bounds.visible = true
			var pos = get_pos()
			light_bounds.margin_top = -350 - pos.y
			light_bounds.margin_bottom = -pos.y
			light_bounds.margin_left = -stage_width - pos.x
			light_bounds.margin_right = stage_width - pos.x
			light1.points[1].x = pos.x +stage_width +10
			light2.points[1].x = pos.x +stage_width - 10
			
			if !lights_on:
				if light1.default_color.a <= 0 and light1.default_color.a <= 0:
					light_box = false
					light_bounds.visible = false
	

func tick():
	#print("Minion Vel [ ", current_state().name, "]", get_vel())
	.tick()
	if !is_ghost:
		if lights_on:
			if light1.default_color.a <= 0.5: light1.default_color.a += 0.05
			if light2.default_color.a <= 0.5: light2.default_color.a += 0.05
		else:
			if light1.default_color.a > 0: light1.default_color.a -= 0.05
			if light2.default_color.a > 0: light2.default_color.a -= 0.05
		
	if not color_set and !is_ghost:
		color_set = true
		$"%Pull_String".default_color = AIC
		
		var color1 = AIC
		for C in FX.get_children():
			if "1color" in C.name:
				#print(C.color)
				C.color = color1
				#print(C.color)
			if "light_fade" in C.name:
				var col1 = color1 #keep alpha value
				col1.a = C.color_ramp.colors[1].a
				C.color_ramp.colors[1] = col1
			if "flicker" in C.name:
				C.color_ramp.colors[0] = color1
				C.color_ramp.colors[2] = color1
				C.color_ramp.colors[4] = color1
				var col1 = color1 #keep alpha value
				col1.a = C.color_ramp.colors[5].a
				C.color_ramp.colors[5] = col1
			
	var pos = get_pos()
	if pos.y < 0: set_grounded(false)
	else: set_grounded(true)
	
	if emit_after_images: after_image(image_lifetime, image_alpha, images)
	
	if (current_state().name in ["HurtGrounded", "HurtAerial", "Fallen"]) and hurt_recover <= 7:
		if commandable and command: hurt_recover += 1 
	elif commandable and damage < HITPOINTS:
		hurt_recover = 0
		match command:
			"joust":
				change_state("Joust")
				command = null
			"DP":
				change_state("RunAttacking")
				command = "DP_pt2"
			"dive":
				if is_grounded():
					change_state("RunAttacking")
					command = "Dive_pt2"
				else:
					change_state("NeedleDive")
					command = null
			"pins":
				if is_grounded():
					change_state("RunAttacking")
					command = "pins_pt2"
				else:
					change_state("PinThrow")
					command = null
			"skydrop":
				change_state("Yoinked")
				command = null
#			"thrown":
#				hit_stun = 20
#				command = "throwgrav"
#				change_state("HurtAerial")
			"claw":
				change_state("RunAttacking")
				command = "claw_pt2"
			"swipe":
				change_state("RunAttacking")
				command = "swipe_pt2"
			"destruct":
				change_state("SelfDestruct")
				command = null
	else: hurt_recover = 0

func apply_forces():
	if command in ["thrown", "throwgrav"]:
		apply_forces_no_limit()
	else :
		.apply_forces()

func hit_by(hitbox):
	if hitbox:
		if hitbox.throw:
			return 
		hitlag_ticks = fixed.round(fixed.mul(hitlag_modifier, str(hitbox.victim_hitlag)))
		if objs_map.has(hitbox.host):
			var host = objs_map[hitbox.host]
			var host_hitlag_ticks = fixed.round(fixed.mul(hitlag_modifier, str(hitbox.hitlag_ticks)))
			if apply_hitlag_when_hit_by_melee:
				if host.hitlag_ticks < host_hitlag_ticks:
					host.hitlag_ticks = host_hitlag_ticks
			if free_cancel_on_hit and host.is_in_group("Fighter"):
				host.projectile_free_cancel()
			
		var x = get_hitbox_x_dir(hitbox)
		var y = hitbox.dir_y

		if hitbox.vacuum:
			var vacuum_dir = get_vacuum_dir(hitbox)
			x = vacuum_dir.x
			y = vacuum_dir.y
		elif hitbox.send_away_from_center:
			var vacuum_dir = get_vacuum_dir(hitbox)
			x = fixed.mul(vacuum_dir.x, "-1")
			y = fixed.mul(vacuum_dir.y, "-1")

		var knockback_force = fixed.normalized_vec_times(x, y, hitbox.knockback)
		set_facing(Utils.int_sign(fixed.round(x)) * - 1)
		if !hit_by_owner:
			damage += hitbox.damage
			#print("minion takes damage: ", damage)
		if !(current_state().name in ["Launched"]) or damage >= HITPOINTS:
			if is_grounded(): change_state(hitbox.grounded_hit_state)
			else: change_state(hitbox.aerial_hit_state)
			reset_momentum()
			set_vel(knockback_force.x, knockback_force.y)
			hit_stun = hitbox.hitstun_ticks
		commandable = true
		
		if hitbox.rumble:
			rumble(hitbox.screenshake_amount, hitbox.victim_hitlag if hitbox.screenshake_frames < 0 else hitbox.screenshake_frames)
		#print("Minion Got Hit!")
		emit_signal("got_hit")
		
		if hitbox.damage > 30:
			var sound = randi_range(0,1)
			if sound: play_sound("squeak1")
			else: play_sound("squeak2")
	
func apply_projectile_style(obj):
	obj.applied_style = applied_style
	obj.set_material(sprite.get_material())
	obj.sprite.set_material(sprite.get_material())
	if "AIC" in obj: obj.AIC = AIC
	
func get_vacuum_dir(hitbox):
	var pos_x = "0"
	var pos_y = "0"
	var hitbox_host = obj_from_name(hitbox.host)
	if hitbox_host:
		var my_pos = get_pos()
		var diff = {x = hitbox.pos_x - my_pos.x, y = hitbox.pos_x - my_pos.y}
		var dir = fixed.normalized_vec(str(diff.x), str(diff.y))
		pos_x = dir.x
		pos_y = dir.y
	return {x = pos_x, y = pos_y}

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
			var color1 = Color("b800ff")
			if applied_style.has("extra_color_1"): color1 = applied_style.extra_color_1
			var color2 = Color("9badb7")
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
					col1.a = C.color_ramp.colors[2].a
					C.color_ramp.colors[2] = col1
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

func on_got_push_blocked():
	reset_momentum()
	if is_grounded():
		change_state("HurtGrounded")
		apply_force_relative(-8, 0)
	else:
		change_state("HurtAerial")
		apply_force_relative(-6, -3)
	hit_stun = 15

func fizzle():
	pass

func disable():
	pass

func true_disable():
	if self in creator.dolls:
		creator.dolls.erase(self)
	sprite.hide()
	state_machine.hide()
	collision_box.hide()
	marker.hide()
	marker_ghost.hide()

	hurtbox.hide()
	disabled = true
	for hitbox in get_active_hitboxes():
		hitbox.deactivate()
	stop_particles()
