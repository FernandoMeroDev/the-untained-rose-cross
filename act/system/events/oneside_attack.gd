class_name OnesideAttack extends Event

## Attacker Speed Dice
var attacker_speed_dice: SpeedDice

## Attacker Card
var attacker_card: CardResource

## Target Speed Dice
var target_speed_dice: SpeedDice

func _init(
	p_attacker_speed_dice: SpeedDice, 
	p_target_speed_dice: SpeedDice, 
	p_attacker_card: CardResource
):
	attacker_speed_dice = p_attacker_speed_dice
	target_speed_dice = p_target_speed_dice
	attacker_card = p_attacker_card
	# Set references in Speed Dices
	target_speed_dice.targeted_by_enemies.append(attacker_speed_dice)
	attacker_speed_dice.set_enemy_dice_target(target_speed_dice)
	# Set Higher Speed in this event
	higher_speed = attacker_speed_dice.value

## Get Card of Speed Dice
func get_card_of_speed_dice(speed_dice: SpeedDice) -> CardResource:
	var result: CardResource
	if speed_dice.id == attacker_speed_dice.id:
			result = attacker_card
	return result

## Clear Speed Dices References
func clear_speed_dices_references() -> void:
	for speed_dice in target_speed_dice.targeted_by_enemies:
		if speed_dice.id == attacker_speed_dice.id:
			target_speed_dice.targeted_by_enemies.erase(speed_dice)
			break
	attacker_speed_dice.remove_enemy_dice_target()
	attacker_speed_dice.battle_event = null
