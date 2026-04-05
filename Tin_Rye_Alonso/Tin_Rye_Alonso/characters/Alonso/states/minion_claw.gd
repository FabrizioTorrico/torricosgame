extends CharacterState

export var command = "claw"

func _enter():
	var pose = host.randi_range(0,4)
	match pose:
		0: anim_name = "Pose1"
		1: anim_name = "Pose2"
		2: anim_name = "Pose3"
		3: anim_name = "Pose4"
		4: anim_name = "Pose5"
		
func _frame_4():
	anim_name = anim_name + "2"

func _frame_6():
	var doll = host.dolls[host.active_minion]
	doll.command = command

func is_usable():
	return .is_usable() and host.dolls.size() > 0
