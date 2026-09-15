extends Control

## Presentation is finished
signal finished

func _ready() -> void:
	$Text.text = "I. Prelude - Rosenkreuz"
	var tween: Tween = create_tween().set_parallel()
	tween.tween_property(
		$Text,
		"modulate:a",
		1.0,
		1.0
	)
	tween.chain().tween_property(
		$Text,
		"modulate:a",
		1.0,
		1.0
	)
	tween.chain().tween_property(
		$Text,
		"modulate:a",
		0.0,
		0.5
	)
	tween.finished.connect(
		func(): finished.emit()
	)
