extends Control

## Emitted when dice value animation tween finished
signal dice_value_setted(value: int)

var dice_queue: Array[DiceResource]

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
	dice_queue = card_resource.dices
	var i: int = 0
	for dice: DiceResource in dice_queue:
		if i == 0:
			$Container/CurrentDice.set_dice(dice)
		else:
			$Container/DiceQueue.add_dice(dice)
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

## Plays current dice
func play_dice() -> void:
	$Container/CurrentDice.play_dice()

## Get current dice value
func get_dice_value() -> int:
	return $Container/CurrentDice.value
