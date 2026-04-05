extends ObjectState

const PIN = preload("res://Tin_Rye_Alonso/characters/Alonso/projectiles/MinionPin.tscn")

func _enter():
	host.emit_after_images = true
	apply_grav = false

func _exit():
	host.emit_after_images = false

func _frame_0():
	var pos = host.get_pos()
	var oppos = host.creator.opponent.get_pos()
	if pos.x - oppos.x >= 0:
		host.set_facing(-1)
	else: host.set_facing(1)

func _frame_5():
	host.apply_force_relative(-3, -4)
	apply_grav = true
	
	var pin = host.spawn_object(PIN, 15, 0, true)
	pin.set_grounded(false)
	pin.set_facing(host.get_facing_int())
	host.apply_projectile_style(pin)
	var force = fixed.normalized_vec_times("5", "5", "10")
	pin.apply_force_relative(force.x, force.y)
	var angle = float( fixed.vec_to_angle(fixed.mul(force.x, str(1)), force.y) )
	pin.sprite.rotation = angle
	pin.particles.rotation = angle
	
	pin = host.spawn_object(PIN, 6, 6, true)
	pin.set_grounded(false)
	pin.set_facing(host.get_facing_int())
	host.apply_projectile_style(pin)
	force = fixed.normalized_vec_times("2", "4", "10")
	pin.apply_force_relative(force.x, force.y)
	angle = float( fixed.vec_to_angle(fixed.mul(force.x, str(1)), force.y) )
	pin.sprite.rotation = angle
	pin.particles.rotation = angle
	
	pin = host.spawn_object(PIN, -7, 8, true)
	pin.set_grounded(false)
	pin.set_facing(host.get_facing_int())
	host.apply_projectile_style(pin)
	force = fixed.normalized_vec_times("0", "3", "10")
	pin.apply_force_relative(force.x, force.y)
	angle = float( fixed.vec_to_angle(fixed.mul(force.x, str(1)), force.y) )
	pin.sprite.rotation = angle
	pin.particles.rotation = angle
