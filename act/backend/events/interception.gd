class_name Interception extends Clash

var interceptor_dice: SpeedDice

var target_dice: SpeedDice

func _init(
	p_target_dice: SpeedDice, 
	p_target_card: CardResource,
	p_attacker_dice: SpeedDice,
	p_attacker_card: CardResource,
):
	super(p_target_dice, p_target_card, p_attacker_dice, p_attacker_card)
	interceptor_dice = p_attacker_dice
	target_dice = p_target_dice
