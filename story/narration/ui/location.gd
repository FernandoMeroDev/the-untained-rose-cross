extends TextureRect

## Set location
func set_location(
	location_name: String = ''
) -> void:
	$Label.text = location_name

## Shows with fade in Effect
func show_location(fade_in_time: float = 0.3) -> void:
	show()
	if fade_in_time > 0.0:
		modulate.a = 0.0
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT_IN)
		tween.tween_property(
			self,
			"modulate:a",
			1.0,
			fade_in_time
		)
