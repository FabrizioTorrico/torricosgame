extends ObjectState

func _enter():
	host.emit_after_images = true

func _exit():
	host.emit_after_images = false
