extends Sprite2D

func init(actor_code: String) -> void:
	texture = load(
		'res://media/act/actors/sprites/' + actor_code + '/effects/guarded.png'
	)

func show_guarded_shock() -> void:
	show()
	# Fade out animation
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.finished.connect(
		func():
			hide()
			modulate.a = 1.0
	)
