extends CharacterState

const PULL_SPEED = "-18"
const pullfx = preload("res://fx/JumpParticle.tscn")

func _enter():
	if host.combo_count > 0: iasa_at = 7
	else: iasa_at = 13

func _frame_7():
	host.tethered = null
	var target = host.obj_local_center(host.opponent)
	var dir = fixed.normalized_vec_times(str(target.x), str(target.y), PULL_SPEED)
	if (host.opponent.current_state().name in ["Knockdown", "Hardknockdown", "Getup"]):
		dir = fixed.normalized_vec_times(str(target.x), "0", PULL_SPEED)
	#print(dir)
	if fixed.ge(dir.y, "0"): dir.y = fixed.mul(dir.y, "1.3")
	host.opponent.apply_force(dir.x, dir.y)
	target = host.opponent.get_hurtbox_center()
	host.spawn_particle_effect(pullfx, Vector2(target.x, target.y), Vector2(dir.x, dir.y))

func is_usable():
	return .is_usable() and (host.tethered == "opp")
