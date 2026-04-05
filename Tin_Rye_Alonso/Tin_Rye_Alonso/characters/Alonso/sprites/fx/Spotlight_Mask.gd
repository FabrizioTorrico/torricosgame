extends Sprite

const MASK = preload("res://Tin_Rye_Alonso/characters/Alonso/sprites/AirDash-Sheet.png")


# Called when the node enters the scene tree for the first time.
func _ready():
	blit_rect_mask ( texture, MASK, Rect2 src_rect, Vector2 dst )
