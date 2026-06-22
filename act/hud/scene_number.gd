extends TextureRect

var turn_manager: TurnManager

func init(scene_number: int) -> void:
	$Number.text = 'Scene ' + str(scene_number)
	animate_fade(self)
	animate_fade($Number)
	animate_shake($Number)
	$Team.show()
	$Team.text = turn_manager.get_readable_team() + ' team starts'
	animate_fade($Team)
	animate_shake($Team)

func animate_fade(node: Control) -> void:
	node.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 1.0, 0.3)
	tween.tween_interval(1.5)
	tween.tween_property(node, "modulate:a", 0, 0.5)
	tween.finished.connect(hide)

func animate_shake(
	node: Control, duration: float = 1.8, strength: float = 8.0
) -> void:
	var original_pos = node.position
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	var steps = 6
	for i in steps:
		var offset = Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		tween.tween_property(node, "position", original_pos + offset, duration / steps)
	tween.tween_property(node, "position", original_pos, duration / steps)
