class_name Clash extends Event

var dice_a: SpeedDice

var dice_a_card: CardResource

var dice_b: SpeedDice

var dice_b_card: CardResource

func _init(
	p_target_dice: SpeedDice, 
	p_target_card: CardResource,
	p_attacker_dice: SpeedDice,
	p_attacker_card: CardResource,
):
	dice_a = p_target_dice
	dice_a_card = p_target_card
	dice_b = p_attacker_dice
	dice_b_card = p_attacker_card
	p_attacker_dice.targeting = p_target_dice
	p_target_dice.targeted_by.append(p_attacker_dice)
	p_target_dice.targeting = p_attacker_dice
	p_attacker_dice.targeted_by.append(p_target_dice)
	dice_a.event = self
	dice_b.event = self

func clear():
	clear_targets(dice_a, dice_b)
	clear_targets(dice_b, dice_a)

func clear_targets(attacker_dice, target_dice):
	for dice in target_dice.targeted_by:
		if dice.id == attacker_dice.id:
			target_dice.targeted_by.erase(dice)
	attacker_dice.targeting = null
	attacker_dice.event = null

func get_card(dice_id) -> CardResource:
	if dice_a.id == dice_id:
		return dice_a_card
	else:
		return dice_b_card
