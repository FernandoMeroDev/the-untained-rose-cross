extends TextureRect

## I don't read finished
signal teasing_finihed

## Tease
func tease() -> void:
	modulate.a = 1.0
	show()
	fade_out(0.5)

## Fade out animation
func fade_out(fade_out_time: float = 0.3) -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(
		self, "modulate:a", 0.0, fade_out_time
	)
	tween.finished.connect(
		func(): teasing_finihed.emit()
	)
