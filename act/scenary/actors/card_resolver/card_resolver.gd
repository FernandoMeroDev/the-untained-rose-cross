extends Control

const EmotionPoint = preload("res://act/hud/actors/actor_control/emotion_points/point.gd")

## Emitted when dice value animation tween finished
signal dice_value_setted(value: int)

## Dice Queue
var dice_queue: Array[DiceResource]

## Parent Actor reference
var parent_actor: Actor

## Is flipped horizontally?
var flip_h: bool = false

# --- --- Value Event Listeners
func _on_value_setted(value: int) -> void:
	dice_value_setted.emit(value)

## Flip Card Horizontally
func flip_h_card(flip: bool) -> void:
	$Portrait.flip_h_portrait(flip)
	$Container.flip_h_container(flip)
	flip_h = flip

## Load Card Resource
func load_card(card_resource: CardResource) -> void:
	$Portrait.load_art(card_resource)
	$Container/Name.text = card_resource.name
	load_dice_queue(card_resource.dices.duplicate())

## Load Defensive dice queue
func load_defensive_dice_queue(defensive_queue: Array[DiceResource]) -> void:
	$Portrait.load_counter_art()
	$Container/Name.text = ''
	load_dice_queue(defensive_queue)

## Load Dice Queue
func load_dice_queue(queue: Array[DiceResource]) -> void:
	dice_queue = queue
	$Container/CurrentDice.set_dice(dice_queue[0])
	dice_queue.remove_at(0)
	var dices: Array[DiceResource]
	if dice_queue.size() > 0:
		if flip_h:
			dices = dice_queue
		else:
			dices = dice_queue.duplicate() as Array[DiceResource]
			dices.reverse()
	for dice: DiceResource in dices:
		$Container/DiceQueue.add_dice(dice)

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
func discard_current_dice() -> void:
	if queue_is_empty():
		$Container/CurrentDice.clear_dice()
	else:
		var new_dice: DiceResource = dice_queue.pop_front()
		$Container/DiceQueue.pop_dice_front()
		$Container/CurrentDice.set_dice(new_dice)

## Pull defensive dices from queue
func pull_defensive_dices() -> Array[DiceResource]:
	var dices: Array[DiceResource] = []
	for dice: DiceResource in dice_queue:
		if dice.is_defensive():
			dices.append(dice)
			dice_queue.erase(dice)
			$Container/DiceQueue.remove_dice(dice)
	return dices

## Play Fade Out current dice animation
func fade_out_current_dice() -> void:
	$Container/CurrentDice.fade_out_dice()

## Recyle current dice
func recycle_current_dice() -> void:
	$Container/CurrentDice.recycle_dice()

## Plays current dice
func play_dice() -> void:
	$Container/CurrentDice.play_dice()
	var dice_value: int = get_dice_value()
	var current_dice: DiceResource = get_current_dice_resource()
	if(
		dice_value == current_dice.max_value
		and dice_value > current_dice.min_value
	):
		parent_actor.emotionalize(1, EmotionPoint.Types.POSITIVE)
	if(
		dice_value == current_dice.min_value
		and dice_value < current_dice.max_value
	):
		parent_actor.emotionalize(1, EmotionPoint.Types.NEGATIVE)

## Destroy current Dice in card resolver
func destroy_current_dice() -> void:
	$Container/CurrentDice.destroy_dice()

## Get current dice value
func get_dice_value() -> int:
	return $Container/CurrentDice.value

## Get current dice max value
func get_current_dice_max_value() -> int:
	return $Container/CurrentDice.dice_resource.max_value

## Get current dice type as String
## For example: slash | blunt | pierce | block | evade
func get_dice_type_string() -> String:
	return $Container/CurrentDice.dice_resource.get_type_code()

## Get Current Dice Resource if any
func get_current_dice_resource() -> DiceResource:
	if has_dice():
		return $Container/CurrentDice.dice_resource
	else:
		return null

## Get all dices
func get_all_dices() -> Array[DiceResource]:
	if has_dice():
		var queue: Array[DiceResource] = [
			get_current_dice_resource()
		]
		if queue_is_not_empty():
			queue.append_array(dice_queue.duplicate())
		return queue
	else:
		return []

## Clear Card Resolver
func clear() -> void:
	dice_queue = []
	$Container/CurrentDice.clear_dice()
	$Container/DiceQueue.clear()
