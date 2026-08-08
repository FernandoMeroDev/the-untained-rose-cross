extends TextureRect

## Presentate Result
func presentate_result() -> void:
	$EndDown.play()
	animate_fade(self)

func animate_fade(node: Control) -> void:
	node.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 1.0, 0.3)
