class_name Event extends RefCounted

## Higher Speed
var higher_speed: int

## Get Card of Speed Dice
func get_card_of_speed_dice(_speed_dice: SpeedDice) -> CardResource:
	push_error("Method not implemented")
	return null

## Get Target of Speed Dice
func get_target_of_speed_dice(_speed_dice) -> SpeedDice:
	push_error("Method not implemented")
	return null

## Get Speed Dices from this Event. No particular order
func get_speed_dices() -> Array[SpeedDice]:
	push_error("Method not implemented")
	return []
