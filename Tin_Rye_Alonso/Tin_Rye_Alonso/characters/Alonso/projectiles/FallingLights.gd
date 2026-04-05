extends BaseProjectile

var delay = 0
var applied_style = null
var hurt_trigger = false

onready var light_bounds = $"%LightBox"
onready var light1 = $"%LightBeam"
onready var light2 = $"%LightBeam2"

#func _enter():
#	light_bounds.margin_left = -stage_width
#	light_bounds.margin_right = stage_width

func _draw():
	var pos = get_pos()
	light_bounds.margin_bottom = -pos.y
	
func tick():
	.tick()
	if !hurt_trigger:
		if creator.is_in_hurt_state():
			hurt_trigger = true
			always_parriable = true
	
	if current_tick <=10:
		light1.default_color.a += 0.05
		light2.default_color.a += 0.05
	
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
					if "1colorb" in C.name:
						C.color = color2
					else: C.color = color1
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
