extends ThrowState

func _enter():
	host.z_index = 2

func _frame_0():
	host.tethered = "opp"

func _frame_16():
	host.combo_proration = 3
