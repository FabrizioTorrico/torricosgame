extends ObjectState

const CONFETTI = preload("res://Tin_Rye_Alonso/characters/Alonso/particles/confetti.tscn")

var timer = 0

func _enter():
	host.commandable = false

func _tick():
	if host.is_grounded(): 
		anim_name = "downed"
		timer += 1
	else: anim_name = "spin"
	
	if timer >= 10:
		host.spawn_particle_effect_relative(CONFETTI, Vector2(0, -8))
		host.true_disable()
