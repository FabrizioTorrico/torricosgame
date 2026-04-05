extends ObjectState

func _enter():
	host.emit_after_images = true
	host.FX.visible = true

func _exit():
	host.emit_after_images = false
	host.FX.visible = false
	host.Skid.visible = false
	host.hit_by_owner = false

func _frame_0():
	host.set_grounded(false)
	host.hit_stun += 15
	var vel = host.get_vel()
	if fixed.ge(vel.x, "0"): host.set_facing(1)
	else:host.set_facing(-1)
	var pos = host.get_pos()
	if host.is_grounded(): 
		anim_name = "skid"
		host.Skid.visible = true
	else: anim_name = "spin"
	
	var vel_mod = fixed.vec_mul(vel.x, vel.y, "0.007")
	var di_strength = fixed.vec_len(vel_mod.x, vel_mod.y)
	var cur_di = host.creator.current_di
	var di_force = fixed.vec_mul(str(cur_di.x), str(cur_di.y), di_strength)
	#print(host.creator.current_di)
	#print(vel_mod, " | ", di_strength, " | ", cur_di, di_force)
	#print("DI Force Modifier - ", di_force)
	host.apply_force(di_force.x, di_force.y)
	
func _tick():
	if host.is_grounded(): 
		anim_name = "skid"
		host.Skid.visible = true
	else: host.Skid.visible = false
	if host.hit_stun < 1:
		host.change_state("Wait")
	host.hit_stun -= 1
