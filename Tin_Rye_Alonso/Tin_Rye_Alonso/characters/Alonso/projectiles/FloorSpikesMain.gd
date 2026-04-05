extends BaseProjectile

var applied_style = null
var dragging: Array = []
var snap = 0
var snap_x = 0
var snap_y = 0

func _ready():
	pass

func tick():
	.tick()
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
				var pos = obj.get_pos()
				#print ("X diff: ",selfpos.x-pos.x,", Y diff: ",selfpos.y-pos.y)
				if selfpos.x - pos.x + (snap_x*get_facing_int()) > snap:
					#print("Moved From x: ",selfpos.x-pos.x)
					pos.x = selfpos.x - snap + (snap_x*get_facing_int())
				elif selfpos.x - pos.x + (snap_x*get_facing_int()) < -snap:
					#print("Moved From x: ",selfpos.x-pos.x)
					pos.x = selfpos.x + snap + (snap_x*get_facing_int())
				if selfpos.y - pos.y + snap_y > snap:
					#print("Moved From y: ",selfpos.y-pos.y+snap_y)
					pos.y = selfpos.y - snap + snap_y
				elif selfpos.y - pos.y + snap_y < -snap:
					#print("Moved From y: ",selfpos.y-pos.y+snap_y)
					pos.y = selfpos.y + snap + snap_y
				#print("Moved To: ",selfpos.x-pos.x,", ",selfpos.y-pos.y)
				#print("Moved To: ",pos.x,", ",pos.y)
				obj.set_pos(pos.x, pos.y)

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
