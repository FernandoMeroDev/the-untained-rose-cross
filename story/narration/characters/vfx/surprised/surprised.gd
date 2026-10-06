extends VFX

const VFX = preload("res://story/narration/characters/vfx/vfx.gd")

## Character Original Position before start animation
var char_original_position: Vector2

## Character Original Scale before start animation
var char_original_scale: Vector2

## Finish Immeditely
func finish_immediately() -> void:
	if character.jumps_surprised_tween:
		character.jumps_surprised_tween.kill()
		character.position = char_original_position
		character.scale = char_original_scale
	if tween:
		tween.kill()
		remove_vfx()

func init() -> void:
	char_original_position = character.position
	char_original_scale = character.scale
	character.jumps_surprised()
	positionate()
	tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, 'modulate:a', 1.0, 0.1)
	tween.tween_property(self, 'scale', scale + Vector2(0.1, 0.1), 0.1)
	tween.chain().tween_property(self, 'modulate:a', 1.0, 0.3)
	tween.chain().tween_property(self, 'modulate:a', 0.0, 0.3)
	tween.finished.connect(remove_vfx)
