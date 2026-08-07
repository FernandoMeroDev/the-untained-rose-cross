extends TextureRect

var original_position: Vector2

func _ready() -> void:
	original_position = position

## Flip Portrait Horizontally
func flip_h_portrait(flip: bool) -> void:
	if flip:
		position = original_position + Vector2(abs(original_position.x) + 100, 0)
		rotation_degrees = -5.0
	else:
		position = original_position
		rotation_degrees = 5.0

## Load Card Resource
func load_art(card_resource: CardResource) -> void:
	$Art.texture = load('res://media/cards/' + card_resource.code + '.png')

## Load Counter Art
func load_counter_art() -> void:
	$Art.texture = preload('res://media/cards/counter.png')
