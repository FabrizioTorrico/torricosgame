extends ObjectState

func _enter():
	host.emit_after_images = true

func _exit():
	host.emit_after_images = false

func _frame_0():
	apply_grav = true

func _frame_4():
	var pos = host.get_pos()
	var oppos = host.creator.opponent.get_pos()
	if pos.x - oppos.x >= 0:
		host.set_facing(-1)
	else: host.set_facing(1)

func _frame_5():
	apply_grav = false
	host.reset_momentum()
	host.apply_force_relative(3, -6)

func _frame_17():
	apply_grav = true
