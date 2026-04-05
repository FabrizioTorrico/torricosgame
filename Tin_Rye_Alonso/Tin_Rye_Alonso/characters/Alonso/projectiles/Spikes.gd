extends ObjectState

onready var hitbox = $Hitbox
onready var hitbox2 = $Hitbox2

func _frame_20():
	fizzle()

func _tick():
	if current_tick <= 5:
		hitbox.parriable = true
		hitbox2.parriable = true
		hitbox.host = host.creator
		hitbox2.host = host.creator
		
	else: 
		hitbox.parriable = false
		hitbox2.parriable = false
		hitbox.host = host
		hitbox2.host = host.creator
	
func fizzle():
	host.disable()
	terminate_hitboxes()
