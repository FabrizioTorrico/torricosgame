extends Node2D

@onready var p1       = $Player1
@onready var p2       = $Player2
@onready var ui_layer = $UI
@onready var Config   = preload("res://config.gd")

enum GameState { RUNNING, DECIDING }
var current_state := GameState.DECIDING

var p1_can_choose := true
var p2_can_choose := true

var p1_queued_type := "idle"
var p1_queued_dir  := Vector2.ZERO
var p2_queued_type := "idle"
var p2_queued_dir  := Vector2.ZERO

var hit_stop_frames := 0

# --- Variables del Preview ---
var preview_timer  := 0.0
var preview_frame  := 0
var preview_frames := 0
var snap_p1 := {}
var snap_p2 := {}
const PREVIEW_SPF := 0.04 # Animación fluida de previsualización

var p1_buttons     := {}
var p2_buttons     := {}
var grid_p1_dash   : GridContainer
var grid_p2_dash   : GridContainer
var p1_status_lbl  : Label
var p2_status_lbl  : Label

const DIRECTIONS = [
	Vector2(-1,-1), Vector2(0,-1), Vector2(1,-1),
	Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0),
	Vector2(-1, 1), Vector2(0, 1), Vector2(1, 1),
]
const DIR_LABELS = ["↖","↑","↗","←","•","→","↙","↓","↘"]

func _ready():
	var screen  = get_viewport_rect().size
	var floor_y = screen.y - Config.UI_HEIGHT

	p1.FLOOR_Y = floor_y
	p2.FLOOR_Y = floor_y
	p1.position = Vector2(Config.GRID_START_X - 3 * Config.GRID_UNIT, floor_y)
	p2.position = Vector2(Config.GRID_START_X + 3 * Config.GRID_UNIT, floor_y)
	p1.opponent = p2
	p2.opponent = p1
	p1.locked_facing_dir = p1.direction_h()
	p2.locked_facing_dir = p2.direction_h()

	_build_floor(floor_y)
	_build_ui()
	_enter_decision(true, true)

func _physics_process(_delta):
	if current_state != GameState.RUNNING: return
	if hit_stop_frames > 0:
		hit_stop_frames -= 1
		return
	_simulate_one_frame()

func _process(delta):
	if current_state == GameState.DECIDING:
		_tick_preview(delta)

# game.gd (Reemplazar la función existente)

func _simulate_one_frame():
	# 1. Guardamos el estado ANTES de procesar el frame
	var p1_was_busy = not p1.is_actionable()
	var p2_was_busy = not p2.is_actionable()

	p1.advance_frame()
	p2.advance_frame()
	_check_collisions()

	# 2. Vemos si acaban de quedar libres EN ESTE FRAME EXACTO
	var p1_now_free = p1_was_busy and p1.is_actionable()
	var p2_now_free = p2_was_busy and p2.is_actionable()

	# El juego SOLO debería pausarse si alguien acaba de terminar un movimiento largo
	var should_pause = p1_now_free or p2_now_free

	# EXCEPCIÓN: Si AMBOS están libres simultáneamente, siempre pausamos
	if p1.is_actionable() and p2.is_actionable():
		should_pause = true

	# Si nadie ha terminado su compromiso, el juego sigue corriendo (Fast-Forward)
	if not should_pause: 
		return

	_enter_decision(p1.is_actionable(), p2.is_actionable())

func _enter_decision(p1_free: bool, p2_free: bool):
	current_state  = GameState.DECIDING
	p1_can_choose  = p1_free
	p2_can_choose  = p2_free

	if p1_free:
		p1_queued_type = "idle"
		p1_queued_dir  = Vector2.ZERO
	if p2_free:
		p2_queued_type = "idle"
		p2_queued_dir  = Vector2.ZERO

	_update_ui()
	_update_button_visuals(1)
	_update_button_visuals(2)
	_start_preview()
	ui_layer.show()

func _on_confirm():
	if current_state != GameState.DECIDING: return
	_stop_preview()
	ui_layer.hide()

	if p1_can_choose:
		p1.begin_turn_with_action(p1_queued_type, p1_queued_dir)
	if p2_can_choose:
		p2.begin_turn_with_action(p2_queued_type, p2_queued_dir)

	current_state = GameState.RUNNING
	
func _check_collisions():
	var body_r := 15
	var hit    := false

	if p1.get_current_pose() == "active" and not p1.has_hit and p1.current_action != "blocking":
		var m = p1.MOVES.get(p1.current_action, {})
		if not m.is_empty():
			var hc = p1.position + p1.aim_dir * m["range"]
			if hc.distance_to(p2.position) <= m["hitbox_radius"] + body_r:
				var sfx = m.get("sfx_hit", null) # Extraer el sonido de impacto de P1
				p2.take_damage(m["damage"], m["hitstun"], p1.aim_dir * m["knockback_force"], sfx)
				p1.has_hit = true
				hit = true

	if p2.get_current_pose() == "active" and not p2.has_hit and p2.current_action != "blocking":
		var m = p2.MOVES.get(p2.current_action, {})
		if not m.is_empty():
			var hc = p2.position + p2.aim_dir * m["range"]
			if hc.distance_to(p1.position) <= m["hitbox_radius"] + body_r:
				var sfx = m.get("sfx_hit", null) # Extraer el sonido de impacto de P2
				p1.take_damage(m["damage"], m["hitstun"], p2.aim_dir * m["knockback_force"], sfx)
				p2.has_hit = true
				hit = true

	if hit: hit_stop_frames = 5

# --- PREVISUALIZACIÓN REAL (FANTASMAS ANIMADOS) ---
func _start_preview():
	snap_p1 = p1.snapshot()
	snap_p2 = p2.snapshot()
	preview_frames = 30 # Simular un segundo hacia el futuro (aprox 30 frames a 60fps)
	preview_frame = 0
	preview_timer = 0.0
	_apply_preview_frame(0)

func _stop_preview():
	if snap_p1.is_empty(): return
	p1.restore_snapshot(snap_p1)
	p2.restore_snapshot(snap_p2)
	p1.hide_ghost()
	p2.hide_ghost()

func _tick_preview(delta: float):
	if snap_p1.is_empty(): return
	preview_timer += delta
	if preview_timer >= PREVIEW_SPF:
		preview_timer -= PREVIEW_SPF
		preview_frame += 1
		if preview_frame > preview_frames:
			preview_frame = 0 # Repetir en bucle
		_apply_preview_frame(preview_frame)

func _apply_preview_frame(fn: int):
	# 1. Restaurar al estado base
	p1.restore_snapshot(snap_p1)
	p2.restore_snapshot(snap_p2)

	# NUEVO: Silenciamos a los personajes durante esta simulación rápida
	p1.sfx_muted = true
	p2.sfx_muted = true

	# 2. Alimentar los comandos seleccionados
	if p1_can_choose: p1.begin_turn_with_action(p1_queued_type, p1_queued_dir)
	if p2_can_choose: p2.begin_turn_with_action(p2_queued_type, p2_queued_dir)

	# 3. Simular la física hacia el futuro
	for _i in range(fn):
		p1.advance_frame()
		p2.advance_frame()
		_check_collisions_preview()

	# 4. Actualizar la posición del Fantasma
	p1.update_ghost()
	p2.update_ghost()

	# 5. Devolver a los personajes reales a su sitio y devolverles la voz
	p1.restore_snapshot(snap_p1)
	p2.restore_snapshot(snap_p2)
	
	p1.sfx_muted = false
	p2.sfx_muted = false

func _check_collisions_preview():
	var body_r := 15
	if p1.get_current_pose() == "active" and not p1.has_hit and p1.current_action != "blocking":
		var m = p1.MOVES.get(p1.current_action, {})
		if not m.is_empty():
			var hc = p1.position + p1.aim_dir * m["range"]
			if hc.distance_to(p2.position) <= m["hitbox_radius"] + body_r:
				p2.take_damage(m["damage"], m["hitstun"], p1.aim_dir * m["knockback_force"])
				p1.has_hit = true
	if p2.get_current_pose() == "active" and not p2.has_hit and p2.current_action != "blocking":
		var m = p2.MOVES.get(p2.current_action, {})
		if not m.is_empty():
			var hc = p2.position + p2.aim_dir * m["range"]
			if hc.distance_to(p1.position) <= m["hitbox_radius"] + body_r:
				p1.take_damage(m["damage"], m["hitstun"], p2.aim_dir * m["knockback_force"])
				p2.has_hit = true

# --- INTERFAZ ---
func _build_floor(floor_y: float):
	var screen = get_viewport_rect().size
	var l = Line2D.new()
	l.add_point(Vector2(0, floor_y)); l.add_point(Vector2(screen.x, floor_y))
	l.width = 3; l.default_color = Color(0.5,0.5,0.5,0.8); add_child(l)
	var g = Node2D.new(); add_child(g)
	for i in range(-Config.GRID_CELLS_H, Config.GRID_CELLS_H+1):
		var x = Config.GRID_START_X + i * Config.GRID_UNIT
		var t = Line2D.new()
		t.add_point(Vector2(x, floor_y))
		t.add_point(Vector2(x, floor_y + (28 if i%2==0 else 16)))
		t.width = 2 if i%2==0 else 1
		t.default_color = Color(1,1,1, 0.55 if i==0 else 0.2)
		g.add_child(t)

func _build_ui():
	var screen = get_viewport_rect().size
	var ui_h   = Config.UI_HEIGHT
	var panel  = PanelContainer.new()
	panel.custom_minimum_size = Vector2(screen.x, ui_h)
	panel.position = Vector2(0, screen.y - ui_h)
	var sty = StyleBoxFlat.new()
	sty.bg_color = Color(0.06, 0.06, 0.09, 0.97)
	panel.add_theme_stylebox_override("panel", sty)
	ui_layer.add_child(panel)

	var hb = HBoxContainer.new()
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	hb.add_theme_constant_override("separation", 30)
	hb.size = panel.size
	panel.add_child(hb)

	hb.add_child(_make_dashboard(1))

	var cv = VBoxContainer.new()
	cv.alignment = BoxContainer.ALIGNMENT_CENTER
	var confirm = Button.new()
	confirm.text = "▶ EJECUTAR"
	confirm.custom_minimum_size = Vector2(120, 60)
	confirm.add_theme_font_size_override("font_size", 16)
	confirm.pressed.connect(_on_confirm)
	cv.add_child(confirm)
	hb.add_child(cv)

	hb.add_child(_make_dashboard(2))

func _make_dashboard(pn: int) -> VBoxContainer:
	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)

	var r1 = HBoxContainer.new()
	var nm = Label.new(); nm.text = "JUGADOR %d" % pn; nm.add_theme_font_size_override("font_size", 16)
	r1.add_child(nm)
	
	var st = Label.new(); st.text = "   | Tu turno"; st.add_theme_font_size_override("font_size", 14)
	if pn==1: p1_status_lbl = st 
	else: p2_status_lbl = st
	r1.add_child(st)
	vb.add_child(r1)

	var hb = HBoxContainer.new()
	hb.add_theme_constant_override("separation", 20)
	hb.add_child(_make_attack_list(pn))
	hb.add_child(_make_dash_grid(pn))
	vb.add_child(hb)
	return vb

func _make_attack_list(pn: int) -> VBoxContainer:
	var vb = VBoxContainer.new()
	var lbl = Label.new(); lbl.text = "ACCIÓN"
	lbl.add_theme_color_override("font_color", Color(1.0,0.85,0.0))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(lbl)
	var g = GridContainer.new(); g.columns = 2
	for mv in ["jab","clawing","crush","crescent","blocking"]:
		var btn = Button.new()
		btn.text = mv.capitalize()
		btn.custom_minimum_size = Vector2(80,36)
		if pn==1: p1_buttons[mv]=btn 
		else: p2_buttons[mv]=btn
		var p=pn; var m=mv
		btn.pressed.connect(func(): _select(p,m,Vector2.ZERO))
		g.add_child(btn)
	vb.add_child(g)
	return vb

func _make_dash_grid(pn: int) -> VBoxContainer:
	var vb = VBoxContainer.new()
	var lbl = Label.new(); lbl.text = "DASH / WAIT"
	lbl.add_theme_color_override("font_color", Color(0.0,0.85,1.0))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(lbl)
	var g = GridContainer.new(); g.columns = 3
	for i in range(9):
		var btn = Button.new()
		btn.text = DIR_LABELS[i]
		btn.custom_minimum_size = Vector2(38,38)
		btn.add_theme_font_size_override("font_size", 19)
		var key = str(DIRECTIONS[i]) if i!=4 else "idle"
		if pn==1: p1_buttons[key]=btn 
		else: p2_buttons[key]=btn
		var p=pn; var v=DIRECTIONS[i]; var ii=i
		if ii==4:
			btn.pressed.connect(func(): _select(p,"idle",Vector2.ZERO))
		else:
			btn.pressed.connect(func(): _select(p,"dash",v))
		g.add_child(btn)
	vb.add_child(g)
	if pn==1: grid_p1_dash=g 
	else: grid_p2_dash=g
	return vb

func _select(pn: int, type: String, dir: Vector2):
	var can = p1_can_choose if pn==1 else p2_can_choose
	if not can: return
	if pn==1: p1_queued_type=type; p1_queued_dir=dir
	else:      p2_queued_type=type; p2_queued_dir=dir
	_update_button_visuals(pn)
	_start_preview()

func _update_ui():
	_update_panel(1)
	_update_panel(2)

func _update_panel(pn: int):
	var buttons  = p1_buttons if pn==1 else p2_buttons
	var fighter  = p1 if pn==1 else p2
	var can      = p1_can_choose if pn==1 else p2_can_choose
	var dash_g   = grid_p1_dash if pn==1 else grid_p2_dash
	var status_l = p1_status_lbl if pn==1 else p2_status_lbl

	if status_l:
		if can:
			status_l.text = " | ⚡ Tu turno"
			status_l.modulate = Color.LIME
		else:
			status_l.text = " | ⏳ Bloqueado"
			status_l.modulate = Color(1.0, 0.55, 0.1)

	for key in buttons:
		buttons[key].disabled = not can

	if dash_g and can:
		for i in range(9):
			if DIRECTIONS[i].y > 0 and fighter.is_grounded():
				dash_g.get_child(i).disabled = true

func _update_button_visuals(pn: int):
	var buttons  = p1_buttons if pn==1 else p2_buttons
	var sel_type = p1_queued_type if pn==1 else p2_queued_type
	var sel_dir  = p1_queued_dir if pn==1 else p2_queued_dir

	var sty = StyleBoxFlat.new()
	sty.bg_color = Color(0.2,0.4,0.85,1.0)
	sty.set_border_width_all(2)
	sty.border_color = Color(0.45,0.7,1.0)

	for key in buttons:
		var btn = buttons[key]
		var ks  = str(key)
		if ks == sel_type or ks == str(sel_dir):
			btn.add_theme_stylebox_override("normal", sty)
		else:
			btn.remove_theme_stylebox_override("normal")
