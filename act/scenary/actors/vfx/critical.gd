extends Sprite2D

var fade_out_tween: Tween

var scale_tween: Tween

## Show VFX
func show_vfx() -> void:
	self.show()
	fade_out_animation()
	scale_animation()

## Create Fade Our animation in Node
func fade_out_animation(time: float = 0.5) -> void:
	if fade_out_tween:
		fade_out_tween.kill()
		fade_out_tween = null
	fade_out_tween = create_tween()
	# Fade out animation
	fade_out_tween.tween_property(self, "modulate:a", 0.0, time)
	fade_out_tween.finished.connect(
		func():
			hide()
			modulate.a = 1.0
	)

## Create scale animation in Node
func scale_animation(p_scale: float = 2.0, time: float = 0.5) -> void:
	if scale_tween:
		scale_tween.kill()
		scale_tween = null
	scale_tween = create_tween()
	scale_tween.tween_property(
		self,
		 "scale", Vector2.ONE * p_scale, time
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	scale_tween.finished.connect(
		func():
			hide()
			scale = Vector2(1, 1)
	)
