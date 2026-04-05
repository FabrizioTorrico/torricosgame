extends CharacterState

var minion_commanding = true

func _enter():
	var pose = host.randi_range(0,4)
	match pose:
		0: anim_name = "Pose1"
		1: anim_name = "Pose2"
		2: anim_name = "Pose3"
		3: anim_name = "Pose4"
		4: anim_name = "Pose5"
		
	if host.combo_count > 0: iasa_at = 7
	else: iasa_at = 13
		
func _frame_4():
	anim_name = anim_name + "2"

func _frame_6():
	var doll = host.dolls[host.active_minion]
	match host.minion_attack:
		0: doll.command = "joust"
		1: doll.command = "DP"
		2: doll.command = "dive"
		3: doll.command = "pins"
#	if !host.is_ghost:
#		print("Doll ID: ", host.active_minion)
#		print("Doll obj: ", host.dolls[host.active_minion])

func is_usable():
	return .is_usable() and host.dolls.size() > 0
