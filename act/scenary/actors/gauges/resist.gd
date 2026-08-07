extends TextureProgressBar

func take_damage(p_value: int) -> void:
	value -= p_value
	$RP.text = str(int(value))

func recover(p_value: int) -> void:
	value += p_value
	$RP.text = str(int(value))
