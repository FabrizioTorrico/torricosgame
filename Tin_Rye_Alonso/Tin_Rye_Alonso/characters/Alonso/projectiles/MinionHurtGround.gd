extends ObjectState

const AIR_FRIC = "0.015"
const HIT_GRAV = "0.25"
const HIT_FALL_SPEED = "15.0"

var gravity = "0.25"

func _enter():
	if state_name == "Grabbed": return "HurtAerial"
	if host.command == "throwgrav":
		host.command = null
		gravity = fixed.add("0.45", HIT_GRAV)
	else: gravity = HIT_GRAV
		

func _frame_0():
	if state_name == "HurtGrounded": 
		host.set_grounded(true)
		var pose = host.randi_range(0,1)
		if pose: anim_name = "hurt_high"
		else: anim_name = "hurt_low"
	else:
		anim_name = "spin"
		host.set_grounded(false)
	if host.hit_by_owner:
		host.hit_by_owner = false
		host.change_state("Launched")
	
func _tick():
	host.apply_x_fric(AIR_FRIC)
	host.apply_grav_custom(gravity, HIT_FALL_SPEED)
	host.apply_forces_no_limit()
	
	if host.hit_by_owner:
		host.hit_by_owner = false
		host.change_state("Launched")
	elif host.hit_stun < 5 and host.is_grounded():
		host.change_state("Fallen")
		host.hit_stun == 0
	elif host.hit_stun < 1:
		host.change_state("Wait")
	host.hit_stun -= 1
