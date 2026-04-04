# config.gd  — Autoload "Config"
# ============================================================
#   Todos los valores ajustables del juego en un lugar.
#   Godot: Project → Project Settings → Autoload
#          Agregar config.gd con el nombre "Config"
# ============================================================
extends Node

# ----------------------------------------------------------
# GRILLA
# Un GRID_UNIT = una "casilla" de movimiento.
# Ataque: el hitbox llega exactamente a 1 casilla (GRID_UNIT px).
# Dash: el personaje se mueve 1 casilla POR EJE.
#   Horizontal → 50px en X
#   Arriba      → 50px en -Y
#   Diagonal    → 50px en X + 50px en -Y  (NO normalizado)
# ----------------------------------------------------------
# ----------------------------------------------------------
# UI / PARTIDA
# ----------------------------------------------------------

const GRID_UNIT := 80.0

# ----------------------------------------------------------
# FÍSICA (por frame de simulación, no por segundo)
# advance_frame() corre a ritmo fijo; usá estos valores.
# ----------------------------------------------------------
const GRAVITY_PER_FRAME := 4.0   # px/frame hacia abajo cuando está en el aire

# ----------------------------------------------------------
# PROPORCIONES DEL PERSONAJE
# ----------------------------------------------------------
const HEAD_RADIUS := 16
const BODY_WIDTH  := 12
const TORSO_LEN   := 30
const ARM_L1      := 18.0
const ARM_L2      := 18.0
const LEG_L1      := 18.0
const LEG_L2      := 18.0
const FOOT_LEN    := 6

# ----------------------------------------------------------
# POSES — offsets base por estado
# ----------------------------------------------------------
const POSES := {
	"idle": {
		"pelvis": Vector2(0, 3),
		"chest":  Vector2(0, 3),
		"head":   Vector2(0, 3),
		"hand_r": Vector2(38, 22),
		"hand_l": Vector2(-38, 22),
		"foot_r": Vector2(14, 0),
		"foot_l": Vector2(-14, 0),
	},
	"airborne": {
		"pelvis": Vector2(0, 0),
		"chest":  Vector2(0, -5),
		"head":   Vector2(0, -5),
		"hand_r": Vector2(30, -5),
		"hand_l": Vector2(-30, -5),
		"foot_r": Vector2(10, 10),
		"foot_l": Vector2(-10, 10),
	},
}

# ----------------------------------------------------------
# MOVIMIENTOS
# ----------------------------------------------------------
const MOVES := {
	"idle": {
		"startup": 0, "active": 0, "recovery": 0,
		"damage": 0, "range": 0.0, "hitbox_radius": 0,
		"hitstun": 0, "knockback_force": 0.0,
		"color": Color.WHITE,
	},
	"rapido": {
		"startup": 3, "active": 4, "recovery": 8,
		"damage": 10,
		"range": 1.0 * GRID_UNIT,
		"hitbox_radius": 18,
		"hitstun": 10,
		"knockback_force": 30.0,
		"color": Color.YELLOW,
	},
	"dash": {
		"startup": 1, "active": 8, "recovery": 4,
		"damage": 0, "range": 0.0, "hitbox_radius": 0,
		"hitstun": 0, "knockback_force": 0.0,
		# distance_per_axis: cuántos px se mueve en cada eje activo.
		# aim_dir.sign() da (-1,0,1) por eje → movimiento CUADRADO (no circular).
		# Diagonal mueve GRID_UNIT en X Y GRID_UNIT en Y.
		"distance_per_axis": 1.0 * GRID_UNIT,
		"color": Color.CYAN,
	},
}

# ----------------------------------------------------------
# UI / PARTIDA
# ----------------------------------------------------------
# ----------------------------------------------------------
# UI / PARTIDA
# ----------------------------------------------------------
const FRAMES_PER_TURN  := 20
const UI_HEIGHT        := 250.0

# NUEVO: Coordenadas fijas para la grilla global
const GRID_START_X     := 400.0  # El centro de la pantalla (asumiendo 800px ancho)
const GRID_CELLS_H     := 9      # Casillas a la izquierda y derecha del centro
const P1_START_X_FRAC  := 0.3
const P2_START_X_FRAC  := 0.7
const SCREEN_LEFT      := 40.0
const SCREEN_RIGHT     := 760.0
