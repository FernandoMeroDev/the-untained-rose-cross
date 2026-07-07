extends TextureRect

## Dice Resource
var dice_resource: DiceResource

## Dice Value
var value: int

## Set Dice
func set_dice(dice: DiceResource) -> void:
	dice_resource = dice
	$Roulette.start()
	$Range.text = (
		str(dice.min_value) + '~' + str(dice.max_value)
	)
	$Icon.texture = load(
		'res://media/icons/dice_types/' + dice.get_type_code() + '.png'
	)

## Play Dice
func play_dice() -> void:
	var result_value: int = randi_range(
		dice_resource.min_value,
		dice_resource.max_value,
	)
	$Roulette.stop()
	$Range.hide()
	$Value.show()
	$Value.set_value(result_value)
	value = result_value
