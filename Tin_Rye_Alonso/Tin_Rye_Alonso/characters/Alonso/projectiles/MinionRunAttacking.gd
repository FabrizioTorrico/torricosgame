extends ObjectState

onready var JumpFX = preload("res://fx/JumpParticle.tscn")

func _enter():
	host.emit_after_images = true

func _exit():
	host.emit_after_images = false

func _tick():
	var pos = host.get_pos()
	var followpos = host.creator.opponent.get_pos()
	
	if !host.is_grounded():
		apply_custom_x_fric = false 
		anim_name = "jump"
	else: 
		apply_custom_x_fric = true
		anim_name = "default"
		
		if followpos.y <= -20 and abs(followpos.x - pos.x) <= 75:
			var vel = host.get_vel()
			spawn_particle_relative(JumpFX, Vector2(), Vector2(vel.x, -5))
			host.apply_force(0,-5)
			host.set_grounded(false)
			host.play_sound("jump")
		
	if followpos.x - pos.x >= 20:
		anim_name = "run"
		host.set_facing(1)
		host.apply_force(2, 0)
	elif followpos.x - pos.x <= -20:
		host.set_facing(-1)
		anim_name = "run"
		host.apply_force(-2, 0)
		
	match host.command:
		"DP_pt2":
			if abs(followpos.x-pos.x) <= 40:
				host.change_state("DP")
				host.command = null
		"Dive_pt2":
			if abs(followpos.x-pos.x) <= 110:
				host.change_state("NeedleJump")
				host.command = null
		"pins_pt2":
			if abs(followpos.x-pos.x) <= 110:
				host.change_state("PinJump")
				host.command = null
		"claw_pt2":
			if abs(followpos.x-pos.x) <= 70:
				host.change_state("Claw")
				host.command = null
		"swipe_pt2":
			if abs(followpos.x-pos.x) <= 40:
				host.change_state("Swipe")
				host.command = null
