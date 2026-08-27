extends TextureRect

## Animation Tween
var tween: Tween

## Move to position X
func animate_movement(position_x: int) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, 'position', Vector2(position_x, position.y), 0.3)
