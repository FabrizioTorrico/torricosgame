extends ObjectState

func _tick():
	if host.is_grounded():
		host.change_state("Impact")

func _frame_500():
	fizzle()
	
func fizzle():
	host.disable()
	terminate_hitboxes()
