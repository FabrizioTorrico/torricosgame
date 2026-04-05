extends ObjectState

func _enter():
	host.sprite.offset.x = 0
	
func _exit():
	host.sprite.offset.x = 18
