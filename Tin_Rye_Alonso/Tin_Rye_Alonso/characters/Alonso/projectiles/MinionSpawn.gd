extends ObjectState

func _enter():
	if host.is_grounded(): anim_name = "default"
	else: anim_name = "jump"

func _frame_1():
	if host.command == "thrown":
		host.hit_stun = 20
		host.command = "throwgrav"
		host.change_state("HurtAerial")
