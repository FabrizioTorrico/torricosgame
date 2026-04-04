# fighter.gd
# ============================================================
#   Personaje con animación procedural IK.
#
#   FIXES vs versión anterior:
#   - get_current_pose(): dash tiene prioridad sobre is_grounded()
#   - Dash: velocidad por eje (aim_dir.sign()), no normalizado
#   - Acción "nada" (Vector2.ZERO): en piso = idle, en aire = caída libre
#   - No puede bajar del piso (clamp en _apply_gravity_and_floor)
#   - Animación dash con lean separado por eje X e Y
# ============================================================
extends Node2D
class_name Fighter

@onready var Config = preload("res://config.gd")

# ----------------------------------------------------------
# ESTADO
# ----------------------------------------------------------
var health         := 100
var aim_dir        := Vector2.RIGHT
var current_action := ""
var frame_counter  := 0
var has_hit        := false
var is_hurt        := false
var hurt_frames_left := 0

# ----------------------------------------------------------
# FÍSICA
# ----------------------------------------------------------
var FLOOR_Y   := 500.0
var velocity  := Vector2.ZERO
# is_airborne: se activa cuando el dash tiene componente Y negativa (hacia arriba)
# o cuando el knockback lanza al personaje.

# ----------------------------------------------------------
# SISTEMA DE TURNOS
# ----------------------------------------------------------
var pending_recovery_frames := 0
var in_recovery             := false
var _queued_action_name     := ""
var _queued_action_dir      := Vector2.ZERO

# ----------------------------------------------------------
# SHORTCUTS (se cargan en _ready)
# ----------------------------------------------------------
var MOVES       : Dictionary
var HEAD_RADIUS : int
var BODY_WIDTH  : int
var TORSO_LEN   : int
var ARM_L1      : float
var ARM_L2      : float
var LEG_L1      : float
var LEG_L2      : float
var FOOT_LEN    : int
var POSES       : Dictionary

# ----------------------------------------------------------
# VÉRTICES DE ANIMACIÓN (espacio local)
# ----------------------------------------------------------
var v_head   := Vector2.ZERO
var v_chest  := Vector2.ZERO
var v_pelvis := Vector2.ZERO
var v_hand_r := Vector2.ZERO
var v_hand_l := Vector2.ZERO
var v_foot_r := Vector2.ZERO
var v_foot_l := Vector2.ZERO

func _ready():
	MOVES       = Config.MOVES
	HEAD_RADIUS = Config.HEAD_RADIUS
	BODY_WIDTH  = Config.BODY_WIDTH
	TORSO_LEN   = Config.TORSO_LEN
	ARM_L1      = Config.ARM_L1
	ARM_L2      = Config.ARM_L2
	LEG_L1      = Config.LEG_L1
	LEG_L2      = Config.LEG_L2
	FOOT_LEN    = Config.FOOT_LEN
	POSES       = Config.POSES
	_reset_vertices()

func _reset_vertices():
	v_pelvis = Vector2(0, -30)
	v_chest  = v_pelvis + Vector2(0, -TORSO_LEN)
	v_head   = v_chest  + Vector2(0, -HEAD_RADIUS - 2)
	v_hand_r = v_chest + POSES["idle"]["hand_r"]
	v_hand_l = v_chest + POSES["idle"]["hand_l"]
	v_foot_r = POSES["idle"]["foot_r"]
	v_foot_l = POSES["idle"]["foot_l"]

# ----------------------------------------------------------
# ESTADO — ORDEN DE PRIORIDAD CORRECTO
# dash_active ANTES de is_grounded, porque el dash puede
# empezar desde el piso y necesita moverse en Y.
# ----------------------------------------------------------
func get_current_pose() -> String:
	if is_hurt: return "hurt"
	if in_recovery: return "recovery"

	# El dash tiene prioridad sobre el chequeo de piso
	if current_action == "dash":
		var m = MOVES["dash"]
		if frame_counter <= m["startup"] + m["active"]:
			return "dash_active"
		return "recovery"

	# Ahora sí chequeamos si está en el aire (sin acción de dash)
	if not is_grounded(): return "airborne"

	if current_action == "" or current_action == "idle": return "idle"

	var move = MOVES[current_action]
	if frame_counter <= move["startup"]:                    return "startup"
	if frame_counter <= move["startup"] + move["active"]:   return "active"
	return "idle"

func is_grounded() -> bool:
	return position.y >= FLOOR_Y

func direction_h() -> float:
	return 1.0 if position.x < 400.0 else -1.0

# ----------------------------------------------------------
# INICIO DE TURNO
# ----------------------------------------------------------
func begin_turn_with_action(action_name: String, target_direction: Vector2):
	if pending_recovery_frames > 0:
		in_recovery = true
		_queued_action_name = action_name
		_queued_action_dir  = target_direction
	else:
		in_recovery = false
		_apply_action(action_name, target_direction)

func _apply_action(action_name: String, target_direction: Vector2):
	current_action = action_name
	frame_counter  = 0
	has_hit        = false

	# Dirección: si es Vector2.ZERO → "no hacer nada"
	if target_direction == Vector2.ZERO:
		aim_dir = Vector2(direction_h(), 0)
		# Acción vacía: quedamos en idle (en piso) o caemos (en aire)
		current_action = "idle"
		return

	# Para el dash usamos sign() por eje, NO normalizado.
	# Esto da movimiento cuadrado: diagonal = GRID_UNIT en X + GRID_UNIT en Y.
	if action_name == "dash":
		# aim_dir almacena la dirección "conceptual" para la animación
		aim_dir = target_direction.normalized()
		var dist  = Config.MOVES["dash"]["distance_per_axis"]
		var frames = float(Config.MOVES["dash"]["active"])
		# Velocidad por frame = distancia_por_eje / frames_activos
		# sign() da exactamente -1, 0 o 1 por componente
		velocity = Vector2(
			sign(target_direction.x) * dist / frames,
			sign(target_direction.y) * dist / frames
		)
	else:
		aim_dir = target_direction.normalized()

# ----------------------------------------------------------
# AVANCE DE FRAME
# Retorna true cuando el turno debe terminar (fin del active).
# ----------------------------------------------------------
func advance_frame() -> bool:
	frame_counter += 1

	# Purgar recovery pendiente del turno anterior
	if in_recovery:
		pending_recovery_frames -= 1
		if pending_recovery_frames <= 0:
			in_recovery = false
			if _queued_action_name != "":
				_apply_action(_queued_action_name, _queued_action_dir)
				_queued_action_name = ""
		return false

	# Hitstun
	if is_hurt:
		hurt_frames_left -= 1
		if hurt_frames_left <= 0:
			is_hurt = false
		_apply_gravity_and_floor()
		return false

	# Dash: movimiento sin gravedad durante el active
	if current_action == "dash" and get_current_pose() == "dash_active":
		position += velocity
		# Clamp: no salir de pantalla, no bajar del piso
		position.x = clamp(position.x, Config.SCREEN_LEFT, Config.SCREEN_RIGHT)
		position.y = clamp(position.y, 10.0, FLOOR_Y)  # 10 = techo mínimo
	else:
		# Idle en aire → caída libre (acción "nada" estando en el aire)
		_apply_gravity_and_floor()
		position.x = clamp(position.x, Config.SCREEN_LEFT, Config.SCREEN_RIGHT)

	# ¿Fin del active? → guardar recovery, terminar turno
	# ¿Fin del active? → guardar recovery, terminar turno
	if current_action != "" and current_action != "idle":
		var move = MOVES[current_action]
		if frame_counter >= move["startup"] + move["active"]:
			pending_recovery_frames = move["recovery"]
			
			if current_action == "dash":
				velocity = Vector2.ZERO
				
				# SNAP TO GRID (Alineación perfecta al terminar el movimiento)
				# Esto fuerza al personaje a aterrizar exactamente en las líneas de la grilla
				var gu = Config.GRID_UNIT
				var center_x = Config.GRID_START_X
				
				# Alineación en X: calculamos a qué casilla está más cerca y lo forzamos ahí
				var grid_index_x = round((position.x - center_x) / gu)
				position.x = center_x + (grid_index_x * gu)
				
				# Alineación en Y: Si saltó en la grilla, lo alineamos a múltiplos de GRID_UNIT desde el piso
				# (Asumiendo que los dash aéreos se mueven en unidades completas de la grilla)
				if is_grounded():
					position.y = FLOOR_Y
				else:
					var dist_from_floor = FLOOR_Y - position.y
					var grid_index_y = round(dist_from_floor / gu)
					position.y = FLOOR_Y - (grid_index_y * gu)
					
			return true

	return false

func _apply_gravity_and_floor():
	if not is_grounded():
		velocity.y += Config.GRAVITY_PER_FRAME
	else:
		velocity.y = 0.0
		# Frenar knockback horizontal al tocar el piso
		velocity.x = move_toward(velocity.x, 0.0, 3.0)

	position.y += velocity.y
	position.x += velocity.x

	# Clamp: NUNCA bajar del piso
	if position.y >= FLOOR_Y:
		position.y = FLOOR_Y
		velocity.y = 0.0

# ----------------------------------------------------------
# RECIBIR DAÑO
# ----------------------------------------------------------
func take_damage(amount: int, hitstun_frames: int, knockback: Vector2):
	health -= amount
	is_hurt = true
	hurt_frames_left = hitstun_frames
	current_action = "idle"
	pending_recovery_frames = 0
	in_recovery = false
	velocity = knockback
	print(name, " recibió ", amount, " de daño. Salud: ", health)

# ----------------------------------------------------------
# ANIMACIÓN — interpola vértices hacia targets cada frame visual
# ----------------------------------------------------------
func _process(delta):
	var pose  = get_current_pose()
	var dir_h = direction_h()
	var d     = aim_dir

	var base_pelvis = Vector2(0, -30)
	var base_chest  = base_pelvis + Vector2(0, -TORSO_LEN)
	var base_head   = base_chest  + Vector2(0, -HEAD_RADIUS - 2)

	var t_pelvis = base_pelvis
	var t_chest  = base_chest
	var t_head   = base_head
	var t_hand_r := Vector2.ZERO
	var t_hand_l := Vector2.ZERO
	var t_foot_r := Vector2(14, 0)
	var t_foot_l := Vector2(-14, 0)

	match pose:
		"idle":
			var p = POSES["idle"]
			t_pelvis += p["pelvis"]
			t_chest  += p["chest"]
			t_head   += p["head"]
			t_hand_r  = t_chest + p["hand_r"]
			t_hand_l  = t_chest + p["hand_l"]
			t_foot_r  = p["foot_r"]
			t_foot_l  = p["foot_l"]

		"startup":
			t_pelvis += Vector2(0, 5)
			t_chest  += -d * 8
			t_head   += -d * 10 + Vector2(0, 5)
			t_hand_r  = t_chest - d * 25
			t_hand_l  = t_chest + d * 10 + Vector2(0, 15)
			t_foot_r  = Vector2(14, 0) - d * 5

		"active":
			t_chest  += d * 10
			t_head   += d * 12
			t_hand_r  = t_chest + d * MOVES[current_action]["range"]
			t_hand_l  = t_chest - d * 15 + Vector2(0, 10)
			t_foot_r  = Vector2(14, 0) + d * 5

		"recovery":
			t_chest  += d * 5 + Vector2(0, 10)
			t_head   += d * 5 + Vector2(0, 12)
			t_hand_r  = t_chest + Vector2(5, 25)
			t_hand_l  = t_chest + Vector2(0, 20)

		"dash_active":
			# Descomponer por eje para lean independiente en X e Y.
			# aim_dir aquí es la dirección normalizada (para la animación).
			var dx = aim_dir.x   # componente horizontal (-1 a 1)
			var dy = aim_dir.y   # componente vertical (-1 = arriba, 1 = abajo)

			# Lean del cuerpo en la dirección del dash
			t_pelvis += Vector2(dx * 6, dy * 8 - 6)
			t_chest  += Vector2(dx * 10, dy * 5)
			t_head   += Vector2(dx * 14, dy * 6)

			# Brazos hacia atrás (trail) + separados si hay componente Y
			var arm_trail = -aim_dir * 18.0
			t_hand_r = t_chest + arm_trail + Vector2(-dx * 3, abs(dy) * 8)
			t_hand_l = t_chest + arm_trail + Vector2( dx * 3, abs(dy) * 8)

			# Piernas: extensión opuesta al movimiento
			# Dash arriba → piernas hacia abajo y abiertas
			# Dash derecha → pierna izquierda queda atrás
			t_foot_r = Vector2(14 + dx * 10, -dy * 10 + abs(dx) * 4)
			t_foot_l = Vector2(-14 + dx * 6,  -dy * 10 + abs(dx) * 2)

		"hurt":
			t_head   += Vector2(-dir_h * 15, -10)
			t_chest  += Vector2(-dir_h * 10, -5)
			t_pelvis += Vector2(0, 10)
			t_hand_r  = t_head + Vector2(10, 0)
			t_hand_l  = t_head + Vector2(-10, 0)

		"airborne":
			var p = POSES["airborne"]
			t_pelvis += p["pelvis"]
			t_chest  += p["chest"]
			t_head   += p["head"]
			t_hand_r  = t_chest + p["hand_r"]
			t_hand_l  = t_chest + p["hand_l"]
			t_foot_r  = p["foot_r"]
			t_foot_l  = p["foot_l"]

	# Lerp suave
	var lerp_speed = 18.0 * delta
	v_head   = v_head.lerp(t_head,     lerp_speed)
	v_chest  = v_chest.lerp(t_chest,   lerp_speed)
	v_pelvis = v_pelvis.lerp(t_pelvis, lerp_speed)
	v_hand_r = v_hand_r.lerp(t_hand_r, lerp_speed)
	v_hand_l = v_hand_l.lerp(t_hand_l, lerp_speed)
	v_foot_r = v_foot_r.lerp(t_foot_r, lerp_speed)
	v_foot_l = v_foot_l.lerp(t_foot_l, lerp_speed)

	queue_redraw()

# ----------------------------------------------------------
# DIBUJO
# ----------------------------------------------------------
func _draw():
	var base_color: Color
	if is_hurt:
		base_color = Color.DARK_RED
	elif current_action != "" and current_action in MOVES:
		base_color = MOVES[current_action]["color"]
	else:
		base_color = Color.WHITE

	# Torso
	draw_line(v_pelvis, v_chest, base_color, BODY_WIDTH, true)
	draw_circle(v_chest,  BODY_WIDTH / 2.0, base_color)
	draw_circle(v_pelvis, BODY_WIDTH / 2.0, base_color)
	# Cabeza
	draw_circle(v_head, HEAD_RADIUS, base_color)

	# Piernas (detrás)
	draw_leg_ik(v_pelvis, v_foot_r, base_color, true)
	draw_leg_ik(v_pelvis, v_foot_l, base_color, false)

	# Brazos
	var pose       = get_current_pose()
	var is_hitting = (pose == "active" and current_action != "dash")
	var r_color    = Color.RED if is_hitting else base_color
	var r_width    = float(BODY_WIDTH + 2) if is_hitting else float(BODY_WIDTH - 2)

	draw_arm_ik(v_chest, v_hand_l, base_color, float(BODY_WIDTH - 2), v_hand_l.x < v_chest.x)
	draw_arm_ik(v_chest, v_hand_r, r_color, r_width, v_hand_r.x < v_chest.x)

	if is_hitting and current_action in MOVES:
		draw_circle(v_hand_r, MOVES[current_action]["hitbox_radius"], Color(1, 0, 0, 0.25))

# ----------------------------------------------------------
# IK
# ----------------------------------------------------------
func draw_arm_ik(shoulder: Vector2, hand: Vector2, color: Color, width: float, flip: bool):
	var elbow = solve_2_bone_ik(shoulder, hand, ARM_L1, ARM_L2, flip)
	draw_line(shoulder, elbow, color, width, true)
	draw_line(elbow, hand, color, width, true)
	draw_circle(shoulder, width / 2.0, color)
	draw_circle(elbow, width / 2.0, color)
	draw_circle(hand, width / 2.0 + 3, color)

func draw_leg_ik(hip: Vector2, ankle: Vector2, color: Color, _flip: bool):
	var final_flip = ankle.x > hip.x
	var knee  = solve_2_bone_ik(hip, ankle, LEG_L1, LEG_L2, final_flip)
	var width = float(BODY_WIDTH - 2)
	draw_line(hip, knee, color, width, true)
	draw_line(knee, ankle, color, width, true)
	draw_circle(hip, width / 2.0, color)
	draw_circle(knee, width / 2.0, color)
	draw_circle(ankle, width / 2.0, color)
	var toe_dir = sign(ankle.x - hip.x)
	if toe_dir == 0: toe_dir = 1.0
	var toe = ankle + Vector2(FOOT_LEN * toe_dir, 2)
	draw_line(ankle, toe, color, width, true)
	draw_circle(toe, width / 2.0, color)

func solve_2_bone_ik(root: Vector2, target: Vector2, l1: float, l2: float, flip_bend: bool) -> Vector2:
	var dir := target - root
	var d   := dir.length()
	if d >= l1 + l2:
		return root + dir.normalized() * l1
	var a      = clamp((l1*l1 + d*d - l2*l2) / (2.0 * l1 * d), -1.0, 1.0)
	var angle1 = dir.angle()
	var angle2 = acos(a)
	if flip_bend: angle1 -= angle2
	else:         angle1 += angle2
	return root + Vector2(cos(angle1), sin(angle1)) * l1
