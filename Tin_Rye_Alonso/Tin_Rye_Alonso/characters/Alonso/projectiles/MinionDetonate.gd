extends ObjectState

const CONFETTI = preload("res://Tin_Rye_Alonso/characters/Alonso/particles/confetti.tscn")

func _frame_9():
	host.spawn_particle_effect_relative(CONFETTI, Vector2(0, -8))
	
func _frame_11():
	fizzle()
	
func fizzle():
	host.disable()
	terminate_hitboxes()
