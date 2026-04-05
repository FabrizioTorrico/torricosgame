extends CharacterState

onready var cord = $"%Pull_String"
export var command = "skydrop"

const string1 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_pull_1.png")
const string2 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_pull_2.png")
const string3 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_pull_3.png")
const string4 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_pulled_1.png")
const string5 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_pulled_2.png")
const string6 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_pulled_3.png")
const string7 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_pulled_4.png")
const string8 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_pulled_5.png")

func _enter():
	if host.combo_count > 0: iasa_at = 7
	else: iasa_at = 13

func _frame_0():
	cord.scale.x = host.get_facing_int()
	cord.points[0].x = 23
	cord.points[0].y = -22
	cord.points[1].x = 23
	cord.points[1].y = -153
	cord.visible = true
	cord.texture = string1
	
func _frame_1():
	cord.texture = string2
	
func _frame_2():
	cord.texture = string3
	host.dolls[host.active_minion].command = command
	host.dolls[host.active_minion].drop_target = host.get_pos().x + ((40 + data.x) * host.get_facing_int())
	
func _frame_7():
	cord.texture = string4
	
func _frame_8():
	cord.texture = string6
	
func _frame_9():
	cord.texture = string8
	
#func _frame_10():
#	cord.texture = string7
	
#func _frame_11():
#	cord.texture = string8
	
func _frame_10():
	cord.visible = false
	
func _exit():
	cord.visible = false
	
func is_usable():
	return .is_usable() and host.dolls.size() > 0
