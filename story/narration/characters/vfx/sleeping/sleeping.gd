extends VFX

const VFX = preload("res://story/narration/characters/vfx/vfx.gd")

func init() -> void:
	positionate()
	scale = Vector2(1.5, 1.5)
	tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, 'modulate:a', 1.0, 0.3)
	tween.chain().tween_property($Z1, 'modulate:a', 1.0, 0.5)
	tween.chain().tween_property($Z2, 'modulate:a', 1.0, 0.5)
	tween.chain().tween_property($Z3, 'modulate:a', 1.0, 0.5)
	tween.chain().tween_property(self, 'modulate:a', 0.0, 0.3)
	tween.finished.connect(remove_vfx)
