class_name Clash extends Event

## Speed Dice A
var speed_dice_a: SpeedDice

## Card Resource A
var card_resource_a: CardResource

## Speed Dice A
var speed_dice_b: SpeedDice

## Card Resource B
var card_resource_b: CardResource

func _init(
	p_attacker_speed_dice: SpeedDice,
	p_attacker_card_resource: CardResource,
	p_target_speed_dice: SpeedDice, 
	p_target_card_resource: CardResource,
):
	speed_dice_a = p_attacker_speed_dice
	card_resource_a = p_attacker_card_resource
	speed_dice_b = p_target_speed_dice
	card_resource_b = p_target_card_resource
	# Set Speed Dice A references
	speed_dice_a.enemy_dice_targeting = speed_dice_b
	speed_dice_a.enemy_dice_intended = speed_dice_b
	speed_dice_a.targeted_by_enemies.append(speed_dice_b)
	# Set Speed Dice B references
	speed_dice_b.enemy_dice_targeting = speed_dice_a
	speed_dice_b.enemy_dice_intended = speed_dice_a
	speed_dice_b.targeted_by_enemies.append(speed_dice_a)

## Get Card Resource of a Speed Dice in this Event
func get_card_of_speed_dice(speed_dice: SpeedDice) -> CardResource:
	var result: CardResource
	match speed_dice.id:
		speed_dice_a.id:
			result = card_resource_a
		speed_dice_b.id:
			result = card_resource_b
	return result

## Derive oneside attack
func derive_oneside_attack(enemy_speed_dice: SpeedDice) -> Dictionary:
	var attacker_dice: SpeedDice
	match enemy_speed_dice.id:
		speed_dice_a.id:
			attacker_dice = speed_dice_b
		speed_dice_b.id:
			attacker_dice = speed_dice_a
	return {
		'attacker_speed_dice': attacker_dice,
		'enemy_speed_dice': enemy_speed_dice,
		'card_resource': get_card_of_speed_dice(attacker_dice)
	}

## Clear Speed Dices References
func clear_speed_dices_references() -> void:
	clear_speed_dice_refereces(speed_dice_a, speed_dice_b)
	clear_speed_dice_refereces(speed_dice_b, speed_dice_a)

## Clear Speed Dice References
func clear_speed_dice_refereces(
	target_speed_dice: SpeedDice,
	attacker_speed_dice: SpeedDice
) -> void:
	for speed_dice in target_speed_dice.targeted_by_enemies:
		if speed_dice.id == attacker_speed_dice.id:
			target_speed_dice.targeted_by_enemies.erase(speed_dice)
			break
	attacker_speed_dice.enemy_dice_intended = null
	attacker_speed_dice.enemy_dice_targeting = null	
	attacker_speed_dice.battle_event = null
