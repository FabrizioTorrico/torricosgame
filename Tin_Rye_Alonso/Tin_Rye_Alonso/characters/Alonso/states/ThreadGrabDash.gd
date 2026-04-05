extends CharacterState

func _frame_0():
	apply_fric = true
	
func _frame_4():
	var vel = host.get_vel()
	if fixed.sign(vel.x) != host.get_facing_int(): host.reset_momentum() 
	apply_fric = false
	host.apply_force_relative(10, 0)

func _frame_12():
	host.change_state("ThreadGrab")

func detect(obj):
	if obj is Fighter:
		host.change_state("ThreadGrab")
