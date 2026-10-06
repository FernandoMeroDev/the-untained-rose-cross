extends Button

func _ready():
	# Animate Glow
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	tween.tween_interval(0.5)
	tween.tween_property(self, "modulate:a", 0.5, 1.0)
	tween.set_loops()
