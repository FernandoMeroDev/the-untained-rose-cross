extends ColorRect

func fade_out() -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(
		self,
		"modulate:a",
		0.0,
		3.0
	)
