extends CharacterState

const MIN_LIST = ["min0", "min1", "min2"]
const FX = preload("res://Tin_Rye_Alonso/characters/Alonso/particles/MinYoink.tscn")
const IMPACT = preload("res://Tin_Rye_Alonso/characters/Alonso/particles/hit_strike_large.tscn")
var minion = null
var hit_something = false

	
func set_minion():
	match host.pred_tethered_minion:
		"min0":
			if host.dolls[0]:
				minion = host.dolls[0]
		"min1":
			if host.dolls[1]:
				minion = host.dolls[1]
		"min2":
			if host.dolls[2]:
				minion = host.dolls[2]
	
func _frame_0():
	apply_forces = true
	apply_grav = true
	host.no_pull = true
	hit_something = false
	iasa_at = 17
	set_minion()
	
func _frame_1():
	if host.is_ghost: set_minion()
	if minion:
		if is_instance_valid(minion):
			minion.change_state("HurtGrounded")
			minion.hit_stun = 12
			
func _frame_2():
	apply_forces = false
	apply_grav = false
	host.reset_momentum()
	if host.is_ghost: set_minion()
	if minion:
		if is_instance_valid(minion):
			minion.after_image(0.4, 0.6)
			var minpos = minion.get_hurtbox_center()
			var pos = host.get_pos()
			var dir_x = pos.x - minpos.x
			var dir_y = pos.y - minpos.y
			host.spawn_particle_effect(FX, Vector2(minpos.x, minpos.y), Vector2(dir_x, dir_y))
			
func _frame_3():
	if host.is_ghost: set_minion()
	if minion:
		if is_instance_valid(minion):
			var pos = host.get_pos()
			minion.set_pos(pos.x + (50 * host.get_facing_int()), pos.y - 8)
			minion.set_vel(-4 * host.get_facing_int(), -2)

func _frame_9():
	Global.current_game.super_freeze_ticks = 15

func _frame_10():
	if host.is_ghost: set_minion()
	#print("Minion? - ",minion)
	if minion:
		if is_instance_valid(minion):
			minion.true_disable()
	host.spawn_particle_effect_relative(IMPACT, Vector2(30, -16), Vector2(host.get_facing_int(), 0))
	host.tethered = null

func _exit():
	host.no_pull = false

func _on_hit_something(o, h):
	._on_hit_something(o, h)
	if o is Fighter: 
		hit_something = true
		iasa_at = 24

func is_usable():
	return .is_usable() and (host.tethered in MIN_LIST)
