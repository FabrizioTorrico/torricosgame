extends CharacterState

var grounded = true

func _enter():
	host.dragging.clear()
	host.snap = 38
	host.snap_x = 0
	host.snap_y = -16
	
func _frame_0():
	apply_fric = true
	grounded = host.is_grounded()
		
func _frame_3():
	apply_fric = false
	if !host.reverse_state:
		host.apply_force_relative(2, 0)
	
func _frame_6():
	if grounded: 
		host.play_sound("jump")
		host.apply_force_relative(1,-5)
	
func _tick():
	if current_tick>=3 and current_tick <=5:
		if !host.reverse_state and grounded:
			host.move_directly_relative(9,0)
	
func _frame_11():
	host.dragging.clear()

func _exit():
	host.dragging.clear()

func _on_hit_something(o, h):
	._on_hit_something(o, h)
	if o is Fighter:
		if not host.dragging.has(o):
			host.dragging.append(o)
			#print("Alonso drag activated")
