extends ObjectState

func _tick():
	if host.delay <= 0: host.change_state("Falling")
	host.delay -= 1
