extends TextureProgressBar

func take_damage(p_value: int) -> void:
	value -= p_value
	$HP.text = str(int(value))
