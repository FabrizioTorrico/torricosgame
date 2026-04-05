extends CharacterState

onready var hbox1 = $Hitbox
onready var hbox2 = $Hitbox2
onready var lowprofile = $HurtboxState
onready var multihit = $Hitbox3

func _enter():
	host.dragging.clear()
	host.snap = 5
	host.snap_x = 33
	host.snap_y = 0

func _frame_0():
	multihit.activated = true
	hbox1.activated = true
	hbox2.activated = true
	apply_fric = true
	apply_custom_x_fric = false

func _tick():
	if current_tick>=4 and current_tick <=5:
		host.move_directly_relative(6,0)
		
func _frame_4():
	apply_fric = false
	host.apply_force_relative(9,0)
	
func _frame_14():
	apply_custom_x_fric = true
	
func _frame_21():
	host.dragging.clear()

func _exit():
	host.dragging.clear()

func _on_hit_something(o, h):
	._on_hit_something(o, h)
	if o is Fighter:
		if not host.dragging.has(o):
			host.dragging.append(o)
			#print("Alonso drag activated")

func on_got_perfect_parried():
	multihit.activated = false
	hbox1.activated = false
	hbox2.activated = false
	lowprofile.end(host)
