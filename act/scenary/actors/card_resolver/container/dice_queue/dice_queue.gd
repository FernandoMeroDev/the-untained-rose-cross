extends HBoxContainer

const DiceScene: PackedScene = preload("res://act/scenary/actors/card_resolver/container/dice_queue/dice/dice.tscn")
const Dice = preload("res://act/scenary/actors/card_resolver/container/dice_queue/dice/dice.gd")

## Add Dice
func add_dice(dice_resource: DiceResource) -> void:
	var dice: Dice = DiceScene.instantiate()
	dice.init(dice_resource)
	add_child(dice)

## Pops dice in queuue
func pop_dice() -> void:
	var node: TextureRect = get_children()[0]
	remove_child(node)
