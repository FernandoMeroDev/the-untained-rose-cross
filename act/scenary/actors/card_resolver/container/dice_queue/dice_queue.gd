extends HBoxContainer

const DiceScene: PackedScene = preload("res://act/scenary/actors/card_resolver/container/dice_queue/dice/dice.tscn")
const Dice = preload("res://act/scenary/actors/card_resolver/container/dice_queue/dice/dice.gd")

## Is flipped Horizontally?
var flip_h: bool = false

## Flip Queue horizontally
func flip_h_queue(flip) -> void:
	flip_h = flip
	var dices: Array = get_children().duplicate()
	dices.reverse()
	for child in get_children():
		remove_child(child)
	for dice in dices:
		add_child(dice)

## Add Dice
func add_dice(dice_resource: DiceResource) -> void:
	var dice: Dice = DiceScene.instantiate()
	dice.init(dice_resource)
	add_child(dice)

## Pops dice in front of queuue
func pop_dice_front() -> void:
	var dices: Array = get_children()
	if dices.size() > 0:
		var dice: Dice = dices[0] if flip_h else dices[dices.size() - 1]
		remove_child(dice)

## Remove Dice from queue
func remove_dice(dice: DiceResource) -> void:
	for dice_node: Dice in get_children():
		if dice_node.dice_resource == dice:
			var tween: Tween = create_tween()
			tween.tween_property(dice_node, "modulate:a", 0.0, 0.3)
			tween.finished.connect(
				func(): remove_child(dice_node)
			)
