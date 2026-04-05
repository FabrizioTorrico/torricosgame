extends ThrowState

const TRAIL = preload("res://Tin_Rye_Alonso/characters/Alonso/particles/EsportsTrail.tscn")
const dashfx = preload("res://Tin_Rye_Alonso/characters/Alonso/particles/JoustParticle.tscn")

onready var hit1 = $Hitbox
onready var hit2 = $Hitbox2

func _frame_0():
	host.dragging.clear()
	host.snap = 5
	host.snap_x = 0
	host.snap_y = 20
	host.dragging.append(host.opponent)

func _frame_6():
	host.no_pull = true
	host.pulling = false
	if host.needle: host.needle.force_return = true
	host.after_image(0.4, 0.6)
	spawn_particle_relative(dashfx, Vector2(), Vector2(0,1))

func _frame_7():
	var pos = host.get_pos()
	host.set_vel(0, 10)
	var height = pos.y
	host.set_pos(pos.x, -15)
	
	while height <= -60:
		host.spawn_particle_effect(TRAIL, Vector2(pos.x, height))
		height += 20

func _frame_10():
	host.dragging.clear()
	
func _frame_12():
	host.combo_proration = 3
	
func _exit():
	host.dragging.clear()
	host.no_pull = false
