extends TextureRect


func init(config):
	$Number.text = 'Scene ' + str(int(config['scene_number']))
	animate_fade(self)
	animate_fade($Number)
	animate_shake($Number)

func animate_fade(node):
	node.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 1.0, 0.3)
	tween.tween_interval(1.5)
	tween.tween_property(node, "modulate:a", 0, 0.5)
	tween.finished.connect(hide)

func animate_shake(node, duration = 1.8, strength = 8.0):
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
