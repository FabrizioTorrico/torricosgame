extends CharacterState

onready var cord = $"%Pull_String"

const MINION = preload("res://Tin_Rye_Alonso/characters/Alonso/projectiles/RainingMinions.tscn")
const LIGHTS = preload("res://Tin_Rye_Alonso/characters/Alonso/projectiles/FallingLights.tscn")

const string1 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_pull_1.png")
const string2 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_pull_2.png")
const string3 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_pull_3.png")
const string4 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_pulled_1.png")
const string5 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_pulled_2.png")
const string6 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_pulled_3.png")
const string7 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_pulled_4.png")
const string8 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_pulled_5.png")

func _enter():
	if host.combo_count > 0: iasa_at = 8
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
	
func _frame_7():
	cord.texture = string4
	
func _frame_8():
	host.LightDropCD = 120
	cord.texture = string6
	host.play_sound("lights_ping")
	host.play_sound("lights_snap")
	
	var pos = host.get_pos()
	var obj = host.spawn_object(LIGHTS, 100+data.x, -500, true)
	obj.set_facing(host.get_facing_int())
	host.apply_projectile_style(obj)
	
	obj = host.spawn_object(MINION, 160+data.x, -500, true)
	obj.set_facing(host.get_facing_int())
	host.apply_projectile_style(obj)
	obj.delay = 20
	obj = host.spawn_object(MINION, 60+data.x, -500, true)
	obj.set_facing(host.get_facing_int())
	host.apply_projectile_style(obj)
	obj.delay = 30
	obj = host.spawn_object(MINION, 110+data.x, -500, true)
	obj.set_facing(host.get_facing_int())
	host.apply_projectile_style(obj)
	obj.delay = 40
	obj = host.spawn_object(MINION, 80+data.x, -500, true)
	obj.set_facing(host.get_facing_int())
	host.apply_projectile_style(obj)
	obj.delay = 50
	obj = host.spawn_object(MINION, 130+data.x, -500, true)
	obj.set_facing(host.get_facing_int())
	host.apply_projectile_style(obj)
	obj.delay = 60
	obj = host.spawn_object(MINION, 40+data.x, -500, true)
	obj.set_facing(host.get_facing_int())
	host.apply_projectile_style(obj)
	obj.delay = 75
	obj = host.spawn_object(MINION, 100+data.x, -500, true)
	obj.set_facing(host.get_facing_int())
	host.apply_projectile_style(obj)
	obj.delay = 90
	obj = host.spawn_object(MINION, 160+data.x, -500, true)
	obj.set_facing(host.get_facing_int())
	host.apply_projectile_style(obj)
	obj.delay = 110
	obj = host.spawn_object(MINION, 60+data.x, -500, true)
	obj.set_facing(host.get_facing_int())
	host.apply_projectile_style(obj)
	obj.delay = 130

#	obj = host.spawn_object(MINION, 110+data.x, -500, true)
#	obj.set_facing(host.get_facing_int())
#	host.apply_projectile_style(obj)
#	obj.delay = 150
#	obj = host.spawn_object(MINION, 80+data.x, -500, true)
#	obj.set_facing(host.get_facing_int())
#	host.apply_projectile_style(obj)
#	obj.delay = 170
	
func _frame_9():
	cord.texture = string8
	
func _frame_10():
	cord.visible = false
	
func _exit():
	cord.visible = false

func is_usable():
	return .is_usable() and host.LightDropCD <= 0
