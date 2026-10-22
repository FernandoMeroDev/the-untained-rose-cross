extends TextureRect

## Presentate Result
func presentate_result(results: Variant) -> void:
	$EndDown.play()
	animate_fade(self)
	if results['victory']:
		$Finished.text = 'ACT_RESULT_VICTORY'
	else:
		$Finished.text = 'ACT_RESULT_DEFEAT'

func animate_fade(node: Control) -> void:
	node.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 1.0, 0.3)
