extends CharacterState

onready var Throwbox = $ThrowBox

func _enter():
	#if !host.is_ghost: print("Command grab start")
	host.z_index = 2

func _frame_0():
	if host.is_grounded():
		Throwbox.hits_vs_grounded = true
		Throwbox.hits_vs_aerial = false
	else:
		Throwbox.hits_vs_grounded = false
		Throwbox.hits_vs_aerial = true
