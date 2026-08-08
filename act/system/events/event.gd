class_name Event extends RefCounted

signal event_resolved(event: Event)

## Higher Speed
var higher_speed: int

## Is this event completed?
var completed: bool = false

## Clear Speed Dices references
func clear_speed_dices_references() -> void:
	push_error("Method not implemented")

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

## Get Actors from this Event. No particular order
func get_actors() -> Array[Actor]:
	var speed_dices: Array[SpeedDice] = get_speed_dices()
	return [
		speed_dices[0].parent_actor,
		speed_dices[1].parent_actor
	]

func emit_event_resolved() -> void:
	event_resolved.emit(self)
