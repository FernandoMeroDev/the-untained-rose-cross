extends Label

signal value_setted(value: int)

## Original font size
var original_font_size: int

func _ready() -> void:
	original_font_size = get_theme_font_size("font_size")

## Set Value
func set_value(value: int) -> void:
	text = str(value)
	add_theme_font_size_override("font_size", original_font_size)
	var tween: Tween = create_tween()
	tween.tween_property(
		self,
		"theme_override_font_sizes/font_size",
		34,
		0.3
	)
	tween.finished.connect(
		func(): 
			value_setted.emit(value)
	)
