extends TextureRect

## Set Emotion Level
func set_level(level: int) -> void:
	match level:
		1: $Level.text = "I"
		2: $Level.text = "II"
		3: $Level.text = "III"
		4: $Level.text = "IV"
		5: $Level.text = "V"
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * 1.3, 0.3)
	tween.chain().tween_property(self, "scale", Vector2.ONE, 0.3)
