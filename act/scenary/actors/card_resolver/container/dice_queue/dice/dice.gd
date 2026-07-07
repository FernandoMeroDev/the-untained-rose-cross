extends TextureRect

func init(dice_resource: DiceResource) -> void:
	$Range.text = (
		str(dice_resource.min_value)
		+ '~'
		+ str(dice_resource.max_value)
	)
	texture = load(
		'res://media/icons/dice_types/' + dice_resource.get_type_code() + '.png'
	)
