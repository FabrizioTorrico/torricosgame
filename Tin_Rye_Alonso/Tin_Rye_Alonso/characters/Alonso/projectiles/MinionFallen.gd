extends ObjectState

#func _enter():
#	host.Skid.visible = true

func _frame_0():
	var vel = host.get_vel()
	if fixed.ge(vel.x, "0"): host.set_facing(1)
	else: host.set_facing(-1)

#func _exit():
#	host.Skid.visible = false
