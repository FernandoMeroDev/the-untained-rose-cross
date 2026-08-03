extends Control


signal fade_animation_finished(tag)

func init(
	value: int, resistence: String, icon_texture: Texture
) -> void:
	$Value.text = str(value)
	$Resistence.text = str(resistence)
	$Icon.texture = icon_texture
	$Delay.timeout.connect(start_fade_animation)

func start_fade_animation() -> void:
	var tween: Tween = create_tween()
	var duration: float = 0.3
	# Up
	tween.parallel().tween_property(
		self,
		"position:y",
		position.y - 40,
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# Fade out
	tween.parallel().tween_property(
		self,
		"modulate:a",
		0.0,
		duration
	)
	# Grow
	tween.parallel().tween_property(
		self,
		"scale",
		scale * 1.2,
		duration
	)
	tween.finished.connect(
		func(): fade_animation_finished.emit(self)
	)
