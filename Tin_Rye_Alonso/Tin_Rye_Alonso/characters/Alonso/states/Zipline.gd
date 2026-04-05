extends CharacterState

var travel_frames = 10
const MIN_SPEED = "15"

func _frame_0():
	host.no_pull = true
	anim_name = "PullString"
	host.opponent.hitlag_ticks = 16
	
func _frame_4():
	anim_name = "AirDash"
	var oppos = host.opponent.get_hurtbox_center()
	var pos = host.get_pos()
	var target_x = oppos.x - pos.x - (20 * host.get_facing_int())
	var target_y = oppos.y - pos.y +14
	
	var min_dist = fixed.mul(str(travel_frames), "10")
	if fixed.lt( fixed.vec_len(str(target_x), str(target_y)), min_dist ):
		travel_frames = fixed.ceil( fixed.div( fixed.vec_len(str(target_x), str(target_y)), MIN_SPEED ) )
	else: travel_frames = 10
	#print("Travel frames = ", travel_frames)
	spawn_particle_relative(particle_scene, Vector2(), Vector2(target_x, target_y))
	
func _tick():
	if current_tick >= 6:
		if travel_frames <= 0: host.change_state("ZipStrike")
		else:
			var oppos = host.opponent.get_hurtbox_center()
			var pos = host.get_pos()
			var target_x = oppos.x - pos.x - (20 * host.get_facing_int())
			var target_y = oppos.y - pos.y +14
			
			#if fixed.lt(fixed.vec_len(str(target_x), str(target_y)), MIN_SPEED):
			if travel_frames == 1:
				host.move_directly(target_x, target_y)
			else:
				var move_x = fixed.ceil( fixed.div(str(target_x), str(travel_frames)) )
				var move_y = fixed.ceil( fixed.div(str(target_y), str(travel_frames)) )
				host.move_directly(move_x, move_y)
				
			travel_frames -= 1
			
func _exit():
	host.tethered = null
	host.no_pull = false
