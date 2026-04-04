# game.gd
# ============================================================
#   Orquestador principal.
#   - UI solo con Ataque (rápido) y Movimiento (dash) + Nada
#   - Grilla visual en el piso mostrando alcance de acciones
#   - Acción "nada": Vector2.ZERO → idle/caída libre según estado
# ============================================================
extends Node2D

@onready var p1       = $Player1
@onready var p2       = $Player2
@onready var ui_layer = $UI
@onready var Config   = preload("res://config.gd")

enum GameState { DECISION, EXECUTION }
var current_state = GameState.DECISION

var execution_frame := 0
var p1_turn_done    := false
var p2_turn_done    := false

var grid_p1_atk  : GridContainer
var grid_p1_dash : GridContainer
var grid_p2_atk  : GridContainer
var grid_p2_dash : GridContainer

var floor_line     : Line2D
var grid_lines_p1  : Node2D   # grilla visual p1
var grid_lines_p2  : Node2D   # grilla visual p2

var p1_queued_type := "rapido"
var p1_queued_dir  := Vector2.RIGHT
var p2_queued_type := "rapido"
var p2_queued_dir  := Vector2.LEFT

# 9 direcciones + Vector2.ZERO para "nada"
const DIRECTIONS = [
	Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1),
	Vector2(-1,  0), Vector2(0,  0), Vector2(1,  0),
	Vector2(-1,  1), Vector2(0,  1), Vector2(1,  1),
]
const DIR_LABELS = ["↖","↑","↗","←","•","→","↙","↓","↘"]

func _ready():
	var screen  = get_viewport_rect().size
	var floor_y = screen.y - Config.UI_HEIGHT

	p1.FLOOR_Y = floor_y
	p2.FLOOR_Y = floor_y
	
	# 1. Posicionar personajes rígidamente en la grilla global
	# P1 empieza 3 casillas a la izquierda del centro, P2 3 a la derecha
	p1.position = Vector2(Config.GRID_START_X - (3 * Config.GRID_UNIT), floor_y)
	p2.position = Vector2(Config.GRID_START_X + (3 * Config.GRID_UNIT), floor_y)

	floor_line = Line2D.new()
	floor_line.add_point(Vector2(0, floor_y))
	floor_line.add_point(Vector2(screen.x, floor_y))
	floor_line.width = 3
	floor_line.default_color = Color(0.5, 0.5, 0.5, 0.8)
	add_child(floor_line)

	# Solo necesitamos un nodo para la grilla estática
	grid_lines_p1 = Node2D.new() 
	add_child(grid_lines_p1)

	_build_ui(Config.UI_HEIGHT)
	_update_ui()
	
	# Dibujamos la grilla estática una sola vez
	_draw_static_floor_grid(floor_y)

# ----------------------------------------------------------
# GRILLA GLOBAL ESTÁTICA
# Dibuja marcas en el piso hacia abajo, indicando las celdas.
# ----------------------------------------------------------
func _draw_static_floor_grid(floor_y: float):
	var gu = Config.GRID_UNIT
	var center_x = Config.GRID_START_X
	var grid_h = 20.0 # Altura de las marcas hacia ABAJO
	
	var tick_color = Color(1.0, 1.0, 1.0, 0.3)
	var center_color = Color(1.0, 1.0, 1.0, 0.6)
	
	# Dibujar desde el centro hacia los bordes
	for i in range(-Config.GRID_CELLS_H, Config.GRID_CELLS_H + 1):
		var x = center_x + (i * gu)
		var col = center_color if i == 0 else tick_color
		var is_main = i % 2 == 0 # Marcas más largas cada 2 casillas
		
		var tick = Line2D.new()
		tick.add_point(Vector2(x, floor_y))
		# Y positivo significa hacia ABAJO en Godot
		tick.add_point(Vector2(x, floor_y + (grid_h * (1.5 if is_main else 1.0))))
		tick.width = 2.0 if is_main else 1.0
		tick.default_color = col
		grid_lines_p1.add_child(tick)

# Elimina las funciones viejas _draw_floor_grids() y _draw_grid_for()
# ----------------------------------------------------------
# GRILLA VISUAL EN EL PISO
# Muestra líneas verticales a distancias de GRID_UNIT desde cada personaje,
# indicando el alcance de ataque (amarillo) y del dash (cian).
# Se redibujan en cada turno porque las posiciones cambian.
# ----------------------------------------------------------
func _draw_floor_grids():
	# Limpiar hijos anteriores
	for child in grid_lines_p1.get_children():
		child.queue_free()
	for child in grid_lines_p2.get_children():
		child.queue_free()

	var floor_y   = p1.FLOOR_Y
	var grid_h    = 40.0   # altura de las marcas de grilla
	var gu        = Config.GRID_UNIT

	# Para cada jugador dibujamos marcas a 1 y 2 unidades en cada dirección
	_draw_grid_for(grid_lines_p1, p1.position.x, floor_y, grid_h, gu, 1)
	_draw_grid_for(grid_lines_p2, p2.position.x, floor_y, grid_h, gu, -1)

func _draw_grid_for(parent: Node2D, px: float, floor_y: float, h: float, gu: float, facing: int):
	var atk_color  = Color(1.0, 0.9, 0.0, 0.7)   # amarillo = alcance ataque
	var dash_color = Color(0.0, 0.9, 1.0, 0.5)   # cian = alcance dash
	var tick_color = Color(1.0, 1.0, 1.0, 0.25)

	# Línea base del piso (tramo local)
	var base = Line2D.new()
	base.add_point(Vector2(px - gu * 2, floor_y))
	base.add_point(Vector2(px + gu * 2, floor_y))
	base.width = 1.5
	base.default_color = tick_color
	parent.add_child(base)

	# Marcas de grilla: -2, -1, 0, +1, +2 en X
	for i in [-2, -1, 0, 1, 2]:
		var x   = px + i * gu
		var col : Color
		if i == 0:
			col = Color(1, 1, 1, 0.6)
		elif abs(i) == 1 and sign(i) == facing:
			col = atk_color       # 1 casilla hacia el frente = alcance ataque
		else:
			col = tick_color

		var tick = Line2D.new()
		tick.add_point(Vector2(x, floor_y))
		tick.add_point(Vector2(x, floor_y - h * (1.5 if i == 0 else 1.0)))
		tick.width = 1.5 if i == 0 else 1.0
		tick.default_color = col
		parent.add_child(tick)

	# Marca del dash: 1 casilla en la dirección de frente (solo en X por ahora)
	var dash_x = px + facing * gu
	var dash_mark = Line2D.new()
	dash_mark.add_point(Vector2(dash_x, floor_y - h * 0.4))
	dash_mark.add_point(Vector2(dash_x, floor_y - h * 1.0))
	dash_mark.width = 3.0
	dash_mark.default_color = dash_color
	parent.add_child(dash_mark)

# ----------------------------------------------------------
# UI
# ----------------------------------------------------------
func _build_ui(ui_height: float):
	var main_panel = PanelContainer.new()
	main_panel.custom_minimum_size = Vector2(get_viewport_rect().size.x, ui_height)
	main_panel.position = Vector2(0, get_viewport_rect().size.y - ui_height)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.08, 0.95)
	main_panel.add_theme_stylebox_override("panel", style)
	ui_layer.add_child(main_panel)

	var h_box = HBoxContainer.new()
	h_box.alignment = BoxContainer.ALIGNMENT_CENTER
	h_box.add_theme_constant_override("separation", 40)
	h_box.size = main_panel.size
	main_panel.add_child(h_box)

	h_box.add_child(_create_player_dashboard(1))

	var btn = Button.new()
	btn.text = "\nEJECUTAR\nTURNO\n"
	btn.custom_minimum_size = Vector2(140, 80)
	btn.add_theme_font_size_override("font_size", 18)
	btn.pressed.connect(_on_confirm_turn)
	h_box.add_child(btn)

	h_box.add_child(_create_player_dashboard(2))

func _create_player_dashboard(player_num: int) -> VBoxContainer:
	var vbox = VBoxContainer.new()
	var title = Label.new()
	title.text = "JUGADOR " + str(player_num)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	vbox.add_child(hbox)

	hbox.add_child(_create_action_grid(player_num, "rapido", "ATAQUE", Color(1.0, 0.9, 0.0)))
	hbox.add_child(_create_action_grid(player_num, "dash",   "MOVIMIENTO", Color(0.0, 0.9, 1.0)))
	return vbox

func _create_action_grid(player_num: int, action_type: String, label_text: String, label_color: Color) -> VBoxContainer:
	var vb  = VBoxContainer.new()
	var lbl = Label.new()
	lbl.text = label_text
	lbl.add_theme_color_override("font_color", label_color)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(lbl)

	var grid = GridContainer.new()
	grid.columns = 3
	for i in range(9):
		var btn = Button.new()
		btn.text = DIR_LABELS[i]
		btn.custom_minimum_size = Vector2(48, 48)
		btn.add_theme_font_size_override("font_size", 26)

		var vec  = DIRECTIONS[i]
		var atype = action_type
		var pnum  = player_num

		# El botón central (•, index 4) = "nada" = Vector2.ZERO
		if i == 4:
			btn.pressed.connect(func(): _set_queued_action(pnum, atype, Vector2.ZERO))
		else:
			btn.pressed.connect(func(): _set_queued_action(pnum, atype, vec))
		grid.add_child(btn)

	vb.add_child(grid)

	# Guardar referencias para update_ui
	if action_type == "rapido":
		if player_num == 1: grid_p1_atk  = grid
		else:               grid_p2_atk  = grid
	else:
		if player_num == 1: grid_p1_dash = grid
		else:               grid_p2_dash = grid

	return vb

func _set_queued_action(player: int, type: String, dir: Vector2):
	if player == 1:
		p1_queued_type = type
		p1_queued_dir  = dir
	else:
		p2_queued_type = type
		p2_queued_dir  = dir

func _update_ui():
	# Deshabilitar flechas hacia abajo cuando está en el piso
	var items = [
		{"grid": grid_p1_atk,  "fighter": p1},
		{"grid": grid_p1_dash, "fighter": p1},
		{"grid": grid_p2_atk,  "fighter": p2},
		{"grid": grid_p2_dash, "fighter": p2},
	]
	for item in items:
		if item["grid"] == null: continue
		for i in range(9):
			var btn = item["grid"].get_child(i)
			var dir = DIRECTIONS[i]
			# Deshabilitamos flechas que van hacia abajo del piso
			# Índices 6,7,8 = abajo-izq, abajo, abajo-der
			btn.disabled = (dir.y > 0 and item["fighter"].is_grounded())

# ----------------------------------------------------------
# TURNO
# ----------------------------------------------------------
func _on_confirm_turn():
	if current_state != GameState.DECISION: return

	p1.begin_turn_with_action(p1_queued_type, p1_queued_dir)
	p2.begin_turn_with_action(p2_queued_type, p2_queued_dir)

	execution_frame = 0
	p1_turn_done    = false
	p2_turn_done    = false
	current_state   = GameState.EXECUTION
	ui_layer.hide()

func _physics_process(_delta):
	if current_state != GameState.EXECUTION: return

	if execution_frame < Config.FRAMES_PER_TURN:
		_simulate_one_frame()
		execution_frame += 1
		if p1_turn_done and p2_turn_done:
			_end_execution()
	else:
		_end_execution()

func _simulate_one_frame():
	if not p1_turn_done: p1_turn_done = p1.advance_frame()
	if not p2_turn_done: p2_turn_done = p2.advance_frame()
	_check_collisions()

func _end_execution():
	current_state = GameState.DECISION
	_update_ui()
	ui_layer.show()

# ----------------------------------------------------------
# COLISIONES
# ----------------------------------------------------------
func _check_collisions():
	var body_radius := 15

	if p1.get_current_pose() == "active" and not p1.has_hit:
		var move = p1.MOVES[p1.current_action]
		var hc = p1.position + p1.aim_dir * move["range"]
		if hc.distance_to(p2.position) <= (move["hitbox_radius"] + body_radius):
			p2.take_damage(move["damage"], move["hitstun"], p1.aim_dir * move["knockback_force"])
			p1.has_hit = true

	if p2.get_current_pose() == "active" and not p2.has_hit:
		var move = p2.MOVES[p2.current_action]
		var hc = p2.position + p2.aim_dir * move["range"]
		if hc.distance_to(p1.position) <= (move["hitbox_radius"] + body_radius):
			p1.take_damage(move["damage"], move["hitstun"], p2.aim_dir * move["knockback_force"])
			p2.has_hit = true
