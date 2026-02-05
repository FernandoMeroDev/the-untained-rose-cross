extends TextureRect


var system

func init(main_system):
	system = main_system
	animate_glow()

func animate_glow():
	$Glow.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property($Glow, "modulate:a", 1.0, 0.5)
	tween.tween_interval(0.5)
	tween.tween_property($Glow, "modulate:a", 0.0, 0.5)
	tween.set_loops()


func _on_dices_pressed() -> void:
	system.roll_speed_dices()
