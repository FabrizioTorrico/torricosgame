extends ObjectState

const MINION_DETONATE = preload("res://Tin_Rye_Alonso/characters/Alonso/projectiles/MinionDestruct.tscn")

func _enter():
	host.commandable = false

func _frame_0():
	var explode = host.spawn_object(MINION_DETONATE, 0, 0, true)
	var vel = host.get_vel()
	explode.set_grounded(false)
	explode.set_vel(vel.x, vel.y)
	explode.set_facing(host.get_facing_int())
	host.apply_projectile_style(explode)
	host.true_disable()
