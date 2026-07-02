extends Node2D

## Get SpeedDices typed Array
func get_speed_dices() -> Array[SpeedDice]:
	var speed_dices: Array[SpeedDice]
	for speed_dice: SpeedDice in get_children():
		speed_dices.append(speed_dice)
	return speed_dices

## Get Speed Dices ordered by Speed. Order descending by default
func get_ordered_by_speed(desc: bool = true) -> Array[SpeedDice]:
	var speed_dices: Array[SpeedDice] = get_speed_dices()
	speed_dices.sort_custom(
		func(speed_dice_a: SpeedDice, speed_dice_b: SpeedDice):
			if speed_dice_a.value > speed_dice_b.value:
				return true
			return false
	)
	if desc:
		return speed_dices
	else:
		speed_dices.reverse()
		return speed_dices

## Find fastest Speed Dice
func get_fastest_speed_dice() -> SpeedDice:
	return get_ordered_by_speed()[0]
