extends Control

## Shows with fade in Effect
func fade_in(time: float = 0.3) -> void:
	show()
	modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(
		self,
		"modulate:a",
		1.0,
		time
	)

## Type text
func type_text(locale: String, line: Dictionary) -> void:
	await $Box/Text.type_text(locale, line)

## Clear dialog
func clear() -> void:
	$Box/Text.text = ''
