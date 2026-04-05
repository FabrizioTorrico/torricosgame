extends CharacterState

var ground = false
const jumpfx = preload("res://fx/JumpParticle.tscn")

func _frame_0():
	ground = false
	if !host.is_grounded():
		current_tick = 2

func _frame_4():
	if host.is_grounded():
		spawn_particle_relative(jumpfx, Vector2(), Vector2(7,-9))
		host.apply_force_relative(7, -9)
		host.move_directly(0, -10)
		ground = true
		
func _frame_8():
	if ground: 
		host.move_directly(12, 0)
		
func _frame_9():
	if ground: 
		host.apply_force(0, 6)

func _exit():
	if ground and current_tick < 9: host.apply_force(0, 6)
