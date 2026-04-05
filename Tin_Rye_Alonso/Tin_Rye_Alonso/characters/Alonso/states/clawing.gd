extends CharacterState

func _frame_4():
	host.apply_force_relative(6, 0)
	
func _tick():
	if current_tick >=4 and current_tick <= 6:
		host.move_directly_relative(6, 0)
