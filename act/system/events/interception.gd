class_name Interception extends Clash

var interceptor_speed_dice: SpeedDice

var target_speed_dice: SpeedDice

func _init(
	p_attacker_speed_dice: SpeedDice,
	p_attacker_card_resource: CardResource,
	p_target_speed_dice: SpeedDice, 
	p_target_card_resource: CardResource,
	p_target_speed_dice_intented: SpeedDice
):
	interceptor_speed_dice = p_attacker_speed_dice
	target_speed_dice = p_target_speed_dice
	super(
		p_attacker_speed_dice,
		p_attacker_card_resource,
		p_target_speed_dice,
		p_target_card_resource,
	)
	# Restore Speed Dice intended due Clash constructor overwirte it
	target_speed_dice.enemy_dice_intended = p_target_speed_dice_intented
