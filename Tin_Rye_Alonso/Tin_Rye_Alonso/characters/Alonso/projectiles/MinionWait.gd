extends ObjectState

func _tick():
	if host.damage >= host.HITPOINTS:
		host.change_state("Dying")
	
	if !host.is_grounded():
		apply_custom_x_fric = false 
		anim_name = "jump"
	else: 
		apply_custom_x_fric = true
		anim_name = "default"
		
		var pos = host.get_pos()
		var followpos = host.creator.get_pos()
		var offset = host.creator.get_facing_int() * -40
		if followpos.x - pos.x + offset >= 20:
			anim_name = "run"
			host.set_facing(1)
			host.apply_force(2, 0)
		elif followpos.x - pos.x +offset <= -20:
			host.set_facing(-1)
			anim_name = "run"
			host.apply_force(-2, 0)
		if followpos.y <= -20 and abs(followpos.x - pos.x + offset) <= 75:
			var vel = host.get_vel()
			spawn_particle_relative(particle_scene, Vector2(), Vector2(vel.x, -5))
			host.apply_force(0,-5)
			host.set_grounded(false)
			host.play_sound("jump")
