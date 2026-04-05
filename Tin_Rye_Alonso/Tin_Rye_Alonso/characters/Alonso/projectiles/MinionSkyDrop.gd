extends ObjectState

func _enter():
	host.emit_after_images = true
	host.FX.visible = true

func _frame_0():
	if !host.is_ghost:
		host.light_box = true
		host.lights_on = true
		var pos = host.get_pos()
		host.light1.points[0].x = pos.x - 180 +host.stage_width
		host.light2.points[0].x = pos.x + 180 +host.stage_width
		#print(host.light1.points[0].x, " | ", host.light2.points[0].x)

func _tick():
	if host.is_grounded():
		host.change_state("SkyDropImpact")
		
	var pos = host.get_pos()
	var oppos = host.creator.opponent.get_pos()
	if pos.x > oppos.x + 2: host.move_directly(-3, 0)
	elif pos.x < oppos.x - 2: host.move_directly(3, 0)

func _exit():
	host.emit_after_images = false
	host.FX.visible = false
	host.lights_on = false
