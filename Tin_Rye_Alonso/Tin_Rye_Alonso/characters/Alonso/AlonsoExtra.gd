extends PlayerExtra

onready var doll1 = $"%doll1"
onready var doll2 = $"%doll2"
onready var doll3 = $"%doll3"
onready var button_list = [$"%doll1", $"%doll2", $"%doll3"]
onready var pull = $"%PullButton"
onready var joust = $"%joust"
onready var dp = $"%dp"
onready var dive = $"%dive"
onready var needle = $"%needle"
onready var explode = $"%destruct"
onready var attack_list = [$"%joust", $"%dp", $"%dive", $"%needle", $"%destruct"]
onready var a_list = $"%AttackContainer"
var doll_select = 0
var attack_select = 0

const ACTIVE = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/UI/Doll.png")
const INACTIVE = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/UI/DollEmpty.png")

func _ready():
	pull.connect("pressed", self, "emit_signal", ["data_changed"])
	doll1.connect("pressed", self, "emit_signal", ["data_changed"])
	doll2.connect("pressed", self, "emit_signal", ["data_changed"])
	doll3.connect("pressed", self, "emit_signal", ["data_changed"])
	doll1.connect("pressed", self, "doll_selected", [doll1])
	doll2.connect("pressed", self, "doll_selected", [doll2])
	doll3.connect("pressed", self, "doll_selected", [doll3])
	joust.connect("pressed", self, "emit_signal", ["data_changed"])
	dp.connect("pressed", self, "emit_signal", ["data_changed"])
	dive.connect("pressed", self, "emit_signal", ["data_changed"])
	needle.connect("pressed", self, "emit_signal", ["data_changed"])
	explode.connect("pressed", self, "emit_signal", ["data_changed"])
	joust.connect("pressed", self, "attack_selected", [joust])
	dp.connect("pressed", self, "attack_selected", [dp])
	dive.connect("pressed", self, "attack_selected", [dive])
	needle.connect("pressed", self, "attack_selected", [needle])
	explode.connect("pressed", self, "attack_selected", [explode])
	
func show_options():
	pull.hide()
	a_list.hide()
	
	pull.set_pressed_no_signal(fighter.pulling)
	if fighter.needle or fighter.tethered:
		pull.show()
	

func reset():
	count_dolls()

func update_selected_move(move_state):
	count_dolls()
	.update_selected_move(move_state)
	if move_state:
		a_list.visible = ("minion_commanding" in move_state)
	
func get_extra():
	return {
		"commanding_minion":doll_select,
		"pull":pull.pressed,
		"minion_attack":attack_select,
		}
		
func count_dolls():
	#print("Doll List: ", fighter.dolls)
	#check host dolls owned to reset if invalid selection
	#also update button visuals
	var size = fighter.dolls.size()
	var counter = 0
	while counter <= 2:
		var num = counter + 1
		if num <= size:
			var button = get("doll" + str(num))
			button.icon = ACTIVE
			button.disabled = false
		else: 
			var button = get("doll" + str(num))
			button.icon = INACTIVE
			button.disabled = true
		counter += 1
		
	if doll3.pressed and size < 3:
		doll3.set_pressed_no_signal(false)
		doll2.set_pressed_no_signal(true)
		doll_select = 1
	if doll2.pressed and size < 2:
		doll2.set_pressed_no_signal(false)
		doll1.set_pressed_no_signal(true)
		doll_select = 0
		
	#print("UI Doll Count - ", size)
	
	counter = 0
	for d in fighter.dolls:
			d.marker.visible = (counter == doll_select)
			counter += 1

func doll_selected(num):
	var count = 0
	for b in button_list:
		if b == num: 
			b.set_pressed_no_signal(true)
			doll_select = count 
		else: b.set_pressed_no_signal(false)
		count += 1
	#print("Selected Doll - ", doll_select, "	 : ", fighter.dolls[doll_select])
	count = 0
	for d in fighter.dolls:
		d.marker.visible = (count == doll_select)
		count += 1
		

func attack_selected(num):
	var count = 0
	for a in attack_list:
		if a == num: 
			a.set_pressed_no_signal(true)
			attack_select = count 
		else: a.set_pressed_no_signal(false)
		count += 1
