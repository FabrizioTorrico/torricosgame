extends ObjectState

func _enter():
	host.lights_on = false

func _frame_0():
	anim_name = "skid"

func _frame_3():
	host.reset_momentum()
	host.apply_force_relative(3, -6)
	anim_name = "spin"
	
func _frame_10():
	host.commandable = true
