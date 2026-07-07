extends Label

signal value_setted(value: int)

## Set Value
func set_value(value: int) -> void:
	text = str(value)
	var tween: Tween = create_tween()
	tween.tween_property(
		self,
		"theme_override_font_sizes/font_size",
		34,
		0.3
	)
	tween.finished.connect(
		func(): value_setted.emit(value)
	)
