extends ThrowState

var cur_di = Vector2(0, 0)

func _enter():
	host.no_pull = true
	host.pulling = false
	if host.needle: host.needle.force_return = true
	
func _frame_1():
	cur_di = host.current_di
	

func _frame_28():
	var di_strength = ("0.04")
	var di_force = fixed.vec_mul(str(cur_di.x), str(cur_di.y), di_strength)
	
	
	var summon = host.spawn_object(host.MINION, 60, -10, true)
	summon.set_facing(host.get_facing_int())
	host.apply_projectile_style(summon)
	#print("Min Throw Force - ", fixed.add("8", di_force.x))
	summon.apply_force(fixed.add(fixed.mul("10", str(host.get_facing_int())), di_force.x),fixed.add("-6", di_force.y))
	summon.command = "thrown"

func _exit():
	host.no_pull = false
