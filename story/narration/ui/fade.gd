extends ColorRect

func fade_in(time_sec: float = 3.0) -> void:
	modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(
		self,
		"modulate:a",
		1.0,
		time_sec
	)

func fade_out(time_sec: float = 0.5) -> void:
	modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(
		self,
		"modulate:a",
		0.0,
		time_sec
	)
