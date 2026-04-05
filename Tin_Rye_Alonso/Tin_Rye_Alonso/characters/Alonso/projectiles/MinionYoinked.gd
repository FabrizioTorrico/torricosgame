extends ObjectState

onready var cord = $"%Pull_String"

const FX = preload("res://Tin_Rye_Alonso/characters/Alonso/particles/MinYoink.tscn")
const string1 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_tether_2.png")
const string2 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_pulled_12.png")
const string3 = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/fx/string_pulled_22.png")

func _enter():
	host.commandable = false

func _frame_0():
	anim_name = "default"
	apply_grav = true
	cord.scale.x = 2 * host.get_facing_int()
	cord.points[0].x = 0
	cord.points[0].y = -12
	cord.points[1].x = 0
	cord.points[1].y = -92
	cord.visible = true
	cord.texture = string2

func _frame_2():
	cord.texture = string3
	cord.points[1].y = -102
	
func _frame_3():
	anim_name = "hurt_high"
	
func _frame_4():
	cord.texture = string3
	cord.points[1].y = -112
	#anim_name = "hurt_high"
	host.after_image(0.4, 0.6)
	host.spawn_particle_effect_relative(FX, Vector2(0, -10), Vector2(0,-1))
	
func _frame_5():
	apply_grav = false
	host.apply_force(0,-24)
	
func _frame_6():
	cord.visible = false
	anim_name = "hidden"
	host.collision_box.width = -1
	host.collision_box.height = -1
	host.hurtbox.width = -1
	host.hurtbox.height = -1
	
func _frame_12():
	host.set_pos(host.drop_target, -300)
	host.change_state("SkyDrop")

func _exit():
	host.collision_box.width = 4
	host.collision_box.height = 8
	host.hurtbox.width = 9
	host.hurtbox.height = 10
