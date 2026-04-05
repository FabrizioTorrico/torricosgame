extends CharacterState

func _enter():
	if host.combo_count > 0: iasa_at = 7
	else: iasa_at = 13

func _frame_7():
	var height = -30
	var force = Vector2(5, -6)
	
	if data:
		if data.x:
			if data.y :
				pass
			else:
				force = Vector2(9, -2)
				height = -8
		else:
			force = Vector2(1, -8)
		
	var summon = host.spawn_object(host.MINION, 30, height, true)
	summon.set_facing(host.get_facing_int())
	host.apply_projectile_style(summon)
	summon.apply_force_relative(str(force.x), str(force.y))
