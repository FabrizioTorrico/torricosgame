extends ObjectState

const RETURN_SPEED = "15"

func _enter():
	host.sprite.offset.x = 18
	var target = host.obj_local_center(host.get_fighter())
	var angle = fixed.vec_to_angle(str(target.x * -1), str(target.y * -1))
	host.sprite.global_rotation = float(angle)

func _tick():
	var target = host.obj_local_center(host.get_fighter())
	var angle = fixed.vec_to_angle(str(target.x * -1), str(target.y * -1))
	var dir = fixed.normalized_vec_times(str(target.x * host.get_facing_int()), str(target.y), RETURN_SPEED)
	
	if fixed.le(fixed.vec_len(str(target.x), str(target.y)), "15"):
		fizzle()
	
	host.move_directly_relative(dir.x, dir.y)
	host.sprite.global_rotation = float(host.get_facing_int()) * float(angle)


func fizzle():
	host.disable()
	terminate_hitboxes()
