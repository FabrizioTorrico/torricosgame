extends ObjectState

func _enter():
	host.emit_after_images = true
	
func _frame_2():
	spawn_particle_relative(particle_scene, Vector2(), Vector2(1, -3))

func _tick():
	if current_tick >= 2:
		host.move_directly_relative(0,-2)

func _exit():
	host.emit_after_images = false
