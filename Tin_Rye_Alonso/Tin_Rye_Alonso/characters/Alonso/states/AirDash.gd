extends CharacterState

const MIN_HEIGHT = 10

var force_x = 0
var force_y = 0
	
func _frame_0():
	if host.reverse_state:
		if host.combo_count <= 0:
			backdash_iasa = true
			beats_backdash = false
			host.hitlag_ticks += 1
			host.add_penalty(5)
		force_x = fixed.div(str(data.x), "15")
	else: 
		force_x = fixed.div(str(data.x), "10")
		backdash_iasa = false
		beats_backdash = true
	force_y = fixed.div(str(data.y), "50")
	
	host.apply_force(force_x, force_y)

func _frame_1():
	spawn_particle_relative(preload("res://fx/DashParticle.tscn"), host.hurtbox_pos_relative_float(), Vector2(force_x, force_y))
	
	
