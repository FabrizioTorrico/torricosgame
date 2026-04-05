extends CharacterState

const NEEDLE = preload("res://Tin_Rye_Alonso/characters/Alonso/projectiles/AlonsoNeedle.tscn")
const string1 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_tether_1.png")
const string2 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_tether_2.png")
const string = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string type2.png")

func _frame_11():
	#var dir = xy_to_dir(data.x, data.y)
	var angle = fixed.vec_to_angle(str(data.x), str(data.y))
	var spawn = fixed.mul("2", fixed.vec_len(str(data.x), str(data.y)))
	spawn = fixed.rotate_vec(spawn, "0", angle)
	var force = fixed.rotate_vec("20", "0", angle)
	
	host.tether.texture = string1
	var needle = host.spawn_object(NEEDLE, fixed.round(spawn.x) * host.get_facing_int(), fixed.round(spawn.y) - 16, true)
	host.apply_projectile_style(needle)
	needle.set_grounded(false)
	needle.set_facing(host.get_facing_int())
	needle.throw_x = fixed.round(force.x)
	needle.throw_y = fixed.round(force.y)
	
func _frame_13():
	host.tether.texture = string2
	
func _frame_15():
	host.tether.texture = string

func _tick():
	if host.tethered == "opp":
		if not "Zipline" in interrupt_into:
			interrupt_into.append("Zipline")

func _exit():
	interrupt_into.erase("Zipline")

func on_got_blocked_by(who):
	if !host.pushblocked:
		if who is Fighter and who.id != host.id:
			host.tethered = "opp"
			if host.needle: host.needle.fizzle()

func is_usable():
	return .is_usable() and !host.needle and !host.tethered

