extends ParticleEffect

onready var sprite = $Sprite




var alpha = 1.0
var mod_alpha = 0.0
var phase = 0.0
var images = 3
var spacing = 1.0

func set_texture(tex):
	sprite.texture = tex

func tick():
	.tick()
	mod_alpha = alpha * clamp((1.0 - ((tick / 60.0) / lifetime)), 0.0, 1.0)
	
	if images > 0:
		spacing = (lifetime * 60)/images
		phase = fmod(tick+1.0, spacing)	
		if (phase < 1): modulate.a = mod_alpha * 1.0
		else: modulate.a = 0.0
	else: modulate.a = mod_alpha
	#print("L:",lifetime," Tck:",tick, " Sp:", spacing, " Ph:", phase)

func set_color(color:Color):
	modulate.r = color.r
	modulate.g = color.g
	modulate.b = color.b
	alpha = color.a
