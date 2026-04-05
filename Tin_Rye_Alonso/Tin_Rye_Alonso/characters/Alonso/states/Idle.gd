extends CharacterState

export  var auto_fall = true

func _enter():
	var prev_anim = host.previous_state().anim_name
	if "Pose" in prev_anim:
		anim_name = prev_anim
	else: anim_name = "Wait"
	if auto_fall:
		if not host.is_grounded():
			return "Fall"

func _tick():
	host.apply_fric()
	host.apply_forces()

	if auto_fall:
		if not host.is_grounded():
			return "Fall"
	if host.hp <= 0:
		return "Knockdown"
