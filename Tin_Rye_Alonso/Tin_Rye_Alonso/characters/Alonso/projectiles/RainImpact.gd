extends ObjectState

func _frame_3():
	fizzle()
	
func fizzle():
	host.disable()
	terminate_hitboxes()
