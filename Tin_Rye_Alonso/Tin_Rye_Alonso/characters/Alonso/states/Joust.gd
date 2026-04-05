extends CharacterState

func _frame_0():
	apply_fric = true
	apply_grav = true
	apply_custom_x_fric = false
	
func _frame_6():
	apply_fric = false
	apply_grav = false
	host.reset_momentum()
	host.apply_force_relative(13, 0)
	host.move_directly_relative(8,0)
	host.start_projectile_invulnerability()
	
func _frame_13():
	apply_custom_x_fric = true
	
func _frame_14():
	host.end_projectile_invulnerability()
	
func _exit():
	host.end_projectile_invulnerability()
