class_name AITeamController extends TeamController

signal ai_enemy_speed_dice_targeted(
	speed_dice: SpeedDice,
	enemy_speed_dice: SpeedDice,
	card_resource: CardResource
)

var allies: Array[Actor]

var enemies: Array[Actor]

func _init(
	p_team: TurnManager.Teams,
	p_allies: Array[Actor],
	p_enemies: Array[Actor],
) -> void:
	type = TeamController.Types.AI
	team = p_team
	allies = p_allies
	enemies = p_enemies

## Each ally target enemy dices
func target_enemies() -> void:
	for ally: Actor in allies:
		for speed_dice: SpeedDice in ally.get_speed_dices():
			target_random_enemy(ally, speed_dice)

## Target random enemy Speed Dice
func target_random_enemy(actor: Actor, speed_dice: SpeedDice) -> void:
	var enemy_actor: Actor = enemies.pick_random()
	var enemy_speed_dice: SpeedDice = enemy_actor\
		.get_speed_dices().pick_random()
	var card_resource: CardResource = actor.pick_random_usable_card()
	if card_resource:
		# [TODO] Connect Signal
		ai_enemy_speed_dice_targeted.emit(
			speed_dice,
			enemy_speed_dice,
			card_resource
		)
