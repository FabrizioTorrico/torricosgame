extends CharacterState

func _frame_6():
	if !host.reverse_state:
		host.apply_force_relative(6,0)
