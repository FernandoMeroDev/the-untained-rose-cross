extends Control

## Emitted when dice value animation tween finished
signal dice_value_setted(value: int)

## Dice Queue
var dice_queue: Array[DiceResource]

## Parent Actor reference
var parent_actor: Actor

# --- --- Value Event Listeners
func _on_value_setted(value: int) -> void:
	dice_value_setted.emit(value)

## Flip Card Horizontally
func flip_h_card(flip: bool) -> void:
	$Portrait.flip_h_portrait(flip)
	$Container.flip_h_container(flip)

## Load Card Resource
func load_card(card_resource: CardResource) -> void:
	$Portrait.load_art(card_resource)
	$Container/Name.text = card_resource.name
	var i: int = 0
	for dice: DiceResource in card_resource.dices:
		if i == 0:
			$Container/CurrentDice.set_dice(dice)
		else:
			$Container/DiceQueue.add_dice(dice)
			dice_queue.append(dice)
		i += 1

## Has Current Dice?
func has_dice() -> bool:
	return $Container/CurrentDice.dice_resource != null

## Queue is empty
func queue_is_empty() -> bool:
	return dice_queue.is_empty()

## Queue is not empty
func queue_is_not_empty() -> bool:
	return not queue_is_empty()

## Discard current dice and load the next in queue
func dicard_current_dice() -> void:
	if queue_is_empty():
		$Container/CurrentDice.clear_dice()
	else:
		var new_dice: DiceResource = dice_queue.pop_back()
		$Container/DiceQueue.pop_dice()
		$Container/CurrentDice.set_dice(new_dice)

## Plays current dice
func play_dice() -> void:
	$Container/CurrentDice.play_dice()

## Destroy current Dice in card resolver
func destroy_current_dice() -> void:
	$Container/CurrentDice.destroy_dice()

## Get current dice value
func get_dice_value() -> int:
	return $Container/CurrentDice.value

## Get current dice type as String
func get_dice_type_string() -> String:
	return $Container/CurrentDice.dice_resource.get_type_code()
