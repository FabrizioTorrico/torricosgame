extends CharacterState

var can_apply_sadness = false

func _enter():
	can_apply_sadness = host.combo_count <= 0
	var pose = host.randi_range(0,7)
	match pose:
		0: anim_name = "Pose1"
		1: anim_name = "Pose2"
		2: anim_name = "Pose3"
		3: anim_name = "Pose4"
		4: anim_name = "Pose5"
		5: anim_name = "Taunt"
		6: anim_name = "Taunt"
		7: anim_name = "Taunt"
	
func _frame_0():
	if !host.is_ghost:
		if !host.light_box: host.play_sound("lights_on")
		host.light_box = true
		host.lights_on = true
		var pos = host.get_pos()
		host.light1.points[0].x = pos.x + (180*host.get_facing_int()) +host.stage_width
		
func _frame_4():
	if "Pose" in anim_name:
		anim_name = anim_name + "2"
		
func _frame_20():
	var pose = host.randi_range(0,4)
	match pose:
		0: 
			if "Pose1" in anim_name: anim_name = "Pose2"
			else: anim_name = "Pose1"
		1: 
			if "Pose2" in anim_name: anim_name = "Pose3"
			else: anim_name = "Pose2"
		2: 
			if "Pose3" in anim_name: anim_name = "Pose4"
			else: anim_name = "Pose3"
		3: 
			if "Pose4" in anim_name: anim_name = "Pose5"
			else: anim_name = "Pose4"
		4: 
			if "Pose5" in anim_name: anim_name = "Pose1"
			else: anim_name = "Pose5"

func _frame_24():
	if "Pose" in anim_name:
		anim_name = anim_name + "2"


func _frame_44():
	host.gain_super_meter_raw(host.MAX_SUPER_METER)
	host.unlock_achievement("ACH_HUSTLE", true)

func _exit():
	host.lights_on = false
