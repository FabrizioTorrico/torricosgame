extends Node

const GRID_UNIT := 60.0
const GRAVITY_PER_FRAME := 4.0

const HEAD_RADIUS := 16
const BODY_WIDTH  := 12
const TORSO_LEN   := 30

const SOUNDS := {
	"swing_light": preload("res://sfx/swish.wav"),
	"swing_heavy": preload("res://sfx/swooshdown.wav"),
	"hit_light":   preload("res://sfx/ping.wav"),
	"hit_heavy":   preload("res://sfx/crunch.wav"),
	"dash":        preload("res://sfx/fwip01.wav"),
	"block":       preload("res://sfx/chime.wav"),
	"hitstun":          preload("res://sfx/crashfade.wav"),
	"ko":          preload("res://sfx/crashfade.wav")
}

# El diccionario de movimientos con "interruptible" integrado
const MOVES := {
	"idle": {
		"startup": 1, "active": 0, "recovery": 0,
		"damage": 0, "range": 0.0, "hitbox_radius": 0,
		"hitstun": 0, "knockback_force": 0.0,
		"color": Color.WHITE,
	},
	"dash": {
		"startup": 2, "active": 8, "recovery": 4, # 14 frames totales
		"damage": 0, "range": 0.0, "hitbox_radius": 0,
		"hitstun": 0, "knockback_force": 0.0,
		"distance_per_axis": 1.5 * GRID_UNIT,
		"color": Color.CYAN,
		"sfx_startup": SOUNDS["dash"] 
	},
	"jab": {
		"startup": 4, "active": 3, "recovery": 7,
		"damage": 6, "range": 1.2 * GRID_UNIT, "hitbox_radius": 18,
		"hitstun": 15, "knockback_force": 10.0,
		"interruptible": false, # Un ataque te compromete
		"color": Color.YELLOW,
		"sfx_startup": SOUNDS["swing_light"],
		"sfx_hit": SOUNDS["hit_light"]
	},
	"clawing": {
		"startup": 6, "active": 4, "recovery": 9,
		"damage": 12, "range": 1.35 * GRID_UNIT, "hitbox_radius": 38,
		"hitstun": 20, "knockback_force": 18.0,
		"interruptible": false,
		"color": Color.ORANGE,
		"sfx_startup": SOUNDS["swing_light"],
		"sfx_hit": SOUNDS["hit_light"]
	},
	"crush": {
		"startup": 12, "active": 5, "recovery": 15,
		"damage": 28, "range": 1.5 * GRID_UNIT, "hitbox_radius": 60,
		"hitstun": 28, "knockback_force": 38.0,
		"interruptible": false,
		"color": Color.RED,
	"sfx_startup": SOUNDS["swing_heavy"],
		"sfx_hit": SOUNDS["hit_heavy"]
	},
	"crescent": {
		"startup": 10, "active": 6, "recovery": 12,
		"damage": 10, "range": 0.1 * GRID_UNIT, "hitbox_radius": 120,
		"hitstun": 18, "knockback_force": 16.0,
		"interruptible": false,
		"color": Color.PURPLE,
		"sfx_startup": SOUNDS["swing_heavy"],
		"sfx_hit": SOUNDS["hit_light"]
	},
	"blocking": {
		"startup": 2, "active": 20, "recovery": 3,
		"damage": 0, "range": 0.0, "hitbox_radius": 0,
		"hitstun": 0, "knockback_force": 0.0,
		"interruptible": false,
		"color": Color.BLUE,
		"sfx_hit": SOUNDS["block"] # Sonido especial si bloquean el ataque
	},
}

const UI_HEIGHT        := 215.0
const GRID_START_X     := 400.0
const GRID_CELLS_H     := 9
const SCREEN_LEFT      := 40.0
const SCREEN_RIGHT     := 760.0
