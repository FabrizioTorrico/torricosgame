extends ObjectState

func _enter():
	host.emit_after_images = true

func _exit():
	host.emit_after_images = false

func _frame_0():
	var pos = host.get_pos()
	var oppos = host.creator.opponent.get_pos()
	if pos.x - oppos.x >= 0:
		host.set_facing(-1)
	else: host.set_facing(1)

func _tick():
	if host.is_grounded():
		host.change_state("Fallen")
