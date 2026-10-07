extends TextureRect

var dice_resource: DiceResource

func init(p_dice_resource: DiceResource) -> void:
	dice_resource = p_dice_resource
	$Range.text = (
		str(dice_resource.min_value)
		+ '~'
		+ str(dice_resource.max_value)
	)
	texture = load(
		'res://media/act/icons/dice_types/' + dice_resource.get_type_code() + '.png'
	)
