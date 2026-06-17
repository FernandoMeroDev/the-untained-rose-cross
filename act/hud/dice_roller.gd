extends TextureRect


var dependencies = {}

func init(dice_roller_dependencies):
	dependencies = dice_roller_dependencies
	animate_glow()

func animate_glow():
	$Glow.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property($Glow, "modulate:a", 1.0, 0.5)
	tween.tween_interval(0.5)
	tween.tween_property($Glow, "modulate:a", 0.0, 0.5)
	tween.set_loops()


func _on_dices_pressed() -> void:
	dependencies['system'].roll_speed_dices()
