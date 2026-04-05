extends BaseProjectile

var applied_style = null
var throw_x = 20
var throw_y = 0
var latched = null
var force_return = false
var returning = false
var holding = false
var pushblocked = false

func init(pos = null):
	.init(pos)
	creator.needle = self
	
func tick():
	.tick()
	if force_return:
		if !returning and !hitlag_ticks:
			returning = true
			change_state("Return")
	elif fighter_owner.pulling and !holding:
		if !fighter_owner.tethered:
			holding = true
			change_state("Hold")
			

func on_state_started(state):
	.on_state_started(state)
	pushblocked = false

func on_got_push_blocked():
	pushblocked = true

func fizzle():
	disable()
