extends ObjectState

onready var hitbox = $SweptHitbox

func _enter():
	host.sprite.offset.x = 18
	var facing = host.get_facing_int()
	host.set_vel(str(host.throw_x), str(host.throw_y) )
	var vel = Vector2(host.throw_x, host.throw_y * facing)
	
	#print("Vel - ", host.get_vel())
	#print("dir - ", vel)
	
	var angle = fixed.vec_to_angle(str(vel.x), str(vel.y))
	var hbox_pos = fixed.rotate_vec(str(10 * facing), "0", angle)
	var hbox_sweep = fixed.rotate_vec(str(32 * facing), "0", angle)
	host.sprite.global_rotation = float(angle)
	hitbox.x = fixed.round(hbox_pos.x)
	hitbox.y = fixed.round(hbox_pos.y)
	hitbox.to_x = fixed.round(hbox_sweep.x)
	hitbox.to_y = fixed.round(hbox_sweep.y)
	
func _tick():
	if current_tick <= 5:
		hitbox.host = host.creator
	else: 
		hitbox.host = host
	
	var vel = host.get_vel()
	#if Vector2(vel.x, vel.y).length() > 2:
	host.set_vel(fixed.mul(str(vel.x),"0.3"), fixed.mul(str(vel.y),"0.3") )
	#else: host.set_vel(0, 0)
	
	if hitbox.active:
		for o in host.objs_map:
			var obj = host.objs_map[o]
			if obj is BaseProjectile:
				if !obj.disabled:
					if obj.id == host.id and "Alonso_Minion" in obj:
						if hitbox.overlaps(obj.hurtbox):
							var count = 0
							while count <= 2:
								if obj == host.creator.dolls[count]:
									#print(obj.name)
									host.creator.tethered = "min" + str(count)
									host.creator.pred_tethered_minion = "min" + str(count)
									#print(host.creator.tethered)
									count = 3
								count += 1
							fizzle()

func on_got_blocked_by(who):
	if !host.pushblocked:
		if who is Fighter and who.id != host.id:
			host.creator.tethered = "opp"
			fizzle()
		#print("Needle Blocked")

func _exit():
	host.sprite.global_rotation = 0

func _on_hit_something(o, h):
	._on_hit_something(o, h)
	if o is Fighter and o.id != host.id:
		host.creator.tethered = "opp"
		fizzle()

func fizzle():
	host.disable()
	terminate_hitboxes()
