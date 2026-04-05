extends Node2D
class_name Fighter

@onready var Config = preload("res://config.gd")
@onready var anim   = $AnimatedSprite2D
@onready var sfx_attack = $SfxAttack     # NUEVO
@onready var sfx_move   = $SfxMovement   # NUEVO

var ghost_anim : AnimatedSprite2D 
var ghost_active := false 
var sfx_muted := false # <--- NUEVA VARIABLE: Silencia la simulación

var health             := 100
var aim_dir            := Vector2.RIGHT
var current_action     := "idle"
var frame_counter      := 0
var has_hit            := false
var is_hurt            := false
var hurt_frames_left   := 0

var FLOOR_Y            := 500.0
var velocity           := Vector2.ZERO
var opponent           : Fighter
var locked_facing_dir  := 1.0

var pending_recovery_frames := 0
var in_recovery             := false

var MOVES : Dictionary

# fighter.gd (Actualizar la función _ready)

func _ready():
	MOVES = Config.MOVES
	
	# NUEVO: Aseguramos que el personaje real siempre esté al frente
	anim.z_index = 10 
	
	# Crear el fantasma visual
	ghost_anim = anim.duplicate()
	ghost_anim.modulate = Color(0.5, 0.8, 1.0, 0.45) 
	ghost_anim.top_level = true 
	
	# NUEVO: Mandamos al fantasma al fondo
	ghost_anim.z_index = 0 
	
	ghost_anim.hide()
	add_child(ghost_anim)

func is_actionable() -> bool:
	if is_hurt:     return false
	if in_recovery: return false
	if current_action != "" and current_action != "idle": return false
	return true

func is_interruptible() -> bool:
	if is_hurt: return false # Si te están pegando, no puedes interrumpir
	var m = MOVES.get(current_action, {})
	return m.get("interruptible", true)

func force_actionable():
	if current_action == "dash":
		velocity = Vector2.ZERO # Conservamos la posición hasta donde llegó
	current_action          = "idle"
	frame_counter           = 0
	in_recovery             = false
	pending_recovery_frames = 0

# 1. EL FIX DE LA PRIORIDAD DE ESTADOS
func get_current_pose() -> String:
	if is_hurt:     return "hurt"
	if in_recovery: return "recovery"
	
	if current_action == "dash":
		var m = MOVES["dash"]
		if frame_counter <= m["startup"] + m["active"]: return "dash_active"
		return "recovery"
		
	# NUEVO: Primero comprobamos si está ejecutando un ataque
	if current_action != "" and current_action != "idle":
		var move = MOVES[current_action]
		if frame_counter <= move["startup"]:                   return "startup"
		if frame_counter <= move["startup"] + move["active"]:  return "active"

	# Si NO está atacando ni en dash, entonces vemos si está en el aire
	if not is_grounded(): return "airborne"
	
	return "idle"


# 2. EL FIX DEL MOMENTUM AL TERMINAR EL DASH
func advance_frame():
	if current_action == "idle" or current_action == "":
		if is_hurt:
			hurt_frames_left -= 1
			if hurt_frames_left <= 0: is_hurt = false
		elif in_recovery:
			pending_recovery_frames -= 1
			if pending_recovery_frames <= 0: in_recovery = false
		_apply_gravity_and_floor()
		position.x = clamp(position.x, Config.SCREEN_LEFT, Config.SCREEN_RIGHT)
		return

	frame_counter += 1

	var m = MOVES[current_action]
	
	# NUEVO: Reproducir sonido de "Swing" o "Dash" justo al terminar el startup
	if frame_counter == m["startup"]:
		if m.has("sfx_startup") and not sfx_muted: # <-- CAMBIO AQUÍ
			sfx_move.stream = m["sfx_startup"]
			sfx_move.play()

	if current_action == "dash" and get_current_pose() == "dash_active":
		position += velocity
		position.x = clamp(position.x, Config.SCREEN_LEFT, Config.SCREEN_RIGHT)
		position.y = clamp(position.y, 10.0, FLOOR_Y)
	else:
		_apply_gravity_and_floor()
		position.x = clamp(position.x, Config.SCREEN_LEFT, Config.SCREEN_RIGHT)

	if frame_counter >= m["startup"] + m["active"]:
		pending_recovery_frames = m["recovery"]
		in_recovery             = true
		
		if current_action == "dash":
			# NUEVO: Solo frenamos en seco si el dash termina en el suelo.
			# En el aire, conservamos 'velocity' para el momentum.
			if is_grounded():
				velocity = Vector2.ZERO
				
		current_action = "idle"
		frame_counter  = 0


# 3. EL FIX DE LA FRICCIÓN AERODINÁMICA
func _apply_gravity_and_floor():
	if not is_grounded(): 
		# En el aire: Aplicamos gravedad y una "fricción de aire" muy suave
		velocity.y += Config.GRAVITY_PER_FRAME
		velocity.x = move_toward(velocity.x, 0.0, 0.5) 
	else: 
		# En el piso: Sin gravedad, y fricción fuerte para frenar rápido
		velocity.y = 0.0
		velocity.x = move_toward(velocity.x, 0.0, 3.0) 
		
	position.y += velocity.y
	position.x += velocity.x
	
	# Clamp para no atravesar el piso
	if position.y >= FLOOR_Y: 
		position.y = FLOOR_Y
		velocity.y = 0.0

func is_grounded() -> bool:
	return position.y >= FLOOR_Y

func direction_h() -> float:
	if opponent:
		if position.x == opponent.position.x: return locked_facing_dir
		return 1.0 if position.x < opponent.position.x else -1.0
	return 1.0 if position.x < Config.GRID_START_X else -1.0


func begin_turn_with_action(action_name: String, target_direction: Vector2):
	# EL FIX: Si el personaje NO está libre, significa que está a mitad
	# de un movimiento largo (como un dash o recibiendo daño).
	# En ese caso, IGNORAMOS la nueva orden y lo dejamos seguir su curso.
	if not is_actionable():
		return
		
	in_recovery             = false
	pending_recovery_frames = 0
	_apply_action(action_name, target_direction)

func _apply_action(action_name: String, target_direction: Vector2):
	current_action    = action_name
	frame_counter     = 0
	has_hit           = false
	locked_facing_dir = direction_h()

	match action_name:
		"idle":
			aim_dir = Vector2(locked_facing_dir, 0)
		"dash":
			aim_dir = target_direction.normalized()
			var dist   = float(Config.MOVES["dash"]["distance_per_axis"])
			var frames = float(Config.MOVES["dash"]["active"])
			velocity = Vector2(
				sign(target_direction.x) * dist / frames,
				sign(target_direction.y) * dist / frames
			)
		"crescent":
			aim_dir = Vector2(locked_facing_dir, -1).normalized()
		"jab","clawing","crush","blocking":
			aim_dir = Vector2(locked_facing_dir, 0)
		_:
			aim_dir = target_direction.normalized() if target_direction != Vector2.ZERO else Vector2(locked_facing_dir, 0)


func take_damage(amount: int, hitstun_frames: int, knockback: Vector2, hit_sound: AudioStream = null):
	if current_action == "blocking" and get_current_pose() == "active":
		velocity = knockback * 0.35
		# Reproducir sonido de bloqueo
		if not sfx_muted and Config.SOUNDS.has("block"):
			sfx_attack.stream = Config.SOUNDS["block"]
			sfx_attack.play()
		return
		
	health          -= amount
	is_hurt          = true
	hurt_frames_left = hitstun_frames
	current_action   = "idle"
	frame_counter    = 0
	pending_recovery_frames = 0
	in_recovery      = false
	velocity         = knockback
	
	# Reproducir el sonido del impacto que nos envió game.gd
	if not sfx_muted and hit_sound != null:
		sfx_attack.stream = hit_sound
		sfx_attack.play()

# --- ANIMACIÓN PRINCIPAL ---
func _process(_delta):
	var pose = get_current_pose()
	if (pose == "idle") and (current_action == "idle" or current_action == ""):
		locked_facing_dir = direction_h()
	anim.flip_h = (locked_facing_dir < 0)
	var ta = _pose_to_anim(pose)
	if anim.animation != ta: anim.play(ta)
	elif not anim.is_playing() and ta != "idle":
		anim.frame = anim.sprite_frames.get_frame_count(ta) - 1

# --- ACTUALIZADOR DEL FANTASMA ---
# ... (dentro de fighter.gd, reemplaza estas tres funciones)

func update_ghost():
	ghost_active = true # <-- Activamos el modo fantasma
	ghost_anim.show()
	ghost_anim.global_position = position
	ghost_anim.flip_h = (locked_facing_dir < 0)
	
	var ta = _pose_to_anim(get_current_pose())
	if ghost_anim.animation != ta:
		ghost_anim.play(ta)

func hide_ghost():
	ghost_active = false # <-- Desactivamos el modo fantasma
	ghost_anim.hide()

# Y actualizamos snapshot() para que también guarde/restaure este estado si fuera necesario
func snapshot() -> Dictionary:
	return {
		"health":                  health,
		"aim_dir":                 aim_dir,
		"current_action":          current_action,
		"frame_counter":           frame_counter,
		"has_hit":                 has_hit,
		"is_hurt":                 is_hurt,
		"hurt_frames_left":        hurt_frames_left,
		"velocity":                velocity,
		"position":                position,
		"locked_facing_dir":       locked_facing_dir,
		"pending_recovery_frames": pending_recovery_frames,
		"in_recovery":             in_recovery,
		"ghost_active":            ghost_active # NUEVO
	}

func restore_snapshot(s: Dictionary):
	health                  = s["health"]
	aim_dir                 = s["aim_dir"]
	current_action          = s["current_action"]
	frame_counter           = s["frame_counter"]
	has_hit                 = s["has_hit"]
	is_hurt                 = s["is_hurt"]
	hurt_frames_left        = s["hurt_frames_left"]
	velocity                = s["velocity"]
	position                = s["position"]
	locked_facing_dir       = s["locked_facing_dir"]
	pending_recovery_frames = s["pending_recovery_frames"]
	in_recovery             = s["in_recovery"]
	ghost_active            = s.get("ghost_active", false) # NUEVO (con valor seguro por defecto)

func _pose_to_anim(pose: String) -> String:
	match pose:
		"hurt":       return "hurt_mid" if is_grounded() else "hurt_air"
		"airborne":   return "fall" if velocity.y > 0 else "jump"
		"dash_active":
			if aim_dir.y < 0:                               return "jump"
			if sign(aim_dir.x) == sign(locked_facing_dir):  return "run"
			return "backdash"
		"startup","active":
			match current_action:
				"jab":      return "jab" if is_grounded() else "air_jab"
				"clawing":  return "clawing"
				"crush":    return "crush"
				"crescent": return "crescent"
				"blocking": return "blocking"
		"recovery": return "idle"
	return "idle"
