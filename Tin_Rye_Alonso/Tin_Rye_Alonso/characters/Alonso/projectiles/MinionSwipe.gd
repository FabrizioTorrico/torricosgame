extends ObjectState

func _enter():
	host.emit_after_images = true

func _exit():
	host.emit_after_images = false

func _frame_1():
	host.reset_momentum()
	host.apply_force_relative(4, -6)
