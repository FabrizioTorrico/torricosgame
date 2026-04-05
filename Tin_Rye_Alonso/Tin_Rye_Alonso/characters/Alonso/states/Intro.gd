extends CharacterState

var state_variables = {}

func _frame_1():
	var face = host.get_facing_int()
	var minion = host.spawn_object(host.MINION, -30, 0, true)
	minion.set_facing(face)
	host.apply_projectile_style(minion)
	minion = host.spawn_object(host.MINION, -55, 0, true)
	minion.set_facing(face)
	host.apply_projectile_style(minion)

func _tick():
	if host.opponent.stance != "Intro" and current_tick < 2:
		for v in state_variables.keys():
			host.opponent.set(v,state_variables[v])
		host.opponent.hitlag_ticks = 1
		host.opponent.state_interruptable = false
	if host.opponent.stance != "Intro" and current_tick >= 2:
		#print("Ready trigger1")
		host.opponent.state_interruptable = true
		host.state_interruptable = true
		host.stance = "Normal"
		return "Wait"
	elif current_tick >= 2:
		host.stance = "Normal"
		return "Wait"
