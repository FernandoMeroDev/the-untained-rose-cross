class_name OnesideAttack extends Event

var attacker_dice: SpeedDice

var attacker_card: CardResource

var target_dice: SpeedDice

func _init(
	input_attacker: SpeedDice, 
	input_target: SpeedDice, 
	input_card_resource: CardResource
):
	attacker_dice = input_attacker
	attacker_card = input_card_resource
	target_dice = input_target
	attacker_dice.targeting = target_dice
	target_dice.targeted_by.append(attacker_dice)
	attacker_dice.event = self

func clear():
	for dice in target_dice.targeted_by:
		if dice.id == attacker_dice.id:
			target_dice.targeted_by.erase(dice)
	attacker_dice.targeting = null
	attacker_dice.event = null

func get_card(_dice_id) -> CardResource:
	return attacker_card
