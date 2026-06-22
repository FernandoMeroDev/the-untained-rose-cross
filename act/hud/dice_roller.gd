extends TextureRect

signal dice_roller_pressed

func init():
	# Animate Glow
	$Glow.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property($Glow, "modulate:a", 1.0, 0.5)
	tween.tween_interval(0.5)
	tween.tween_property($Glow, "modulate:a", 0.0, 0.5)
	tween.set_loops()

func _on_dices_pressed() -> void:
	dice_roller_pressed.emit()
