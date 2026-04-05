extends CharacterState

const SPIKES = preload("res://Tin_Rye_Alonso/characters/Alonso/projectiles/FloorSpikes.tscn")

func _frame_10():
	var pos = host.get_pos()
	var needle = host.spawn_object(SPIKES,200+data.x, -pos.y, true)
	host.apply_projectile_style(needle)
	needle.set_facing(host.get_facing_int())

func _exit():
	host.pinsCD = 15

func is_usable():
	return .is_usable() and host.pinsCD <= 0
