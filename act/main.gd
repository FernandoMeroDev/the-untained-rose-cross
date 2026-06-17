extends Node

enum Phases  { 
	INITIAL, 
	PREPARATION_A, 
	PREPARATION_B, 
	BATTLE 
}

var phase = null

var current_team

var eventCreator: EventCreator

func _ready() -> void:
	eventCreator = EventCreator.new()
	var config = JsonUtils.load_json('res://act/config.json')
	current_team = ['left', 'right'].pick_random()
	$Scenary/Actors.init(
		config,
		{
			'actor_details': $HUD/ActorDetails,
			'hand': $HUD/Hand,
			'arrows': $HUD/Arrows,
			'system': self,
			'sfx': { 'selected': $Music/SFX/Selected }
		}
	)
	$HUD/ActorDetails.init({
		'system': self,
		'actors': $Scenary/Actors,
		'hand': $HUD/Hand,
		'arrows': $HUD/Arrows,
		'sfx': { 'selected': $Music/SFX/Selected }
	})
	$HUD/Actors.init(
		config,
		{
			'actor_details': $HUD/ActorDetails,
			'scenary.actors': $Scenary/Actors,
		}
	)
	$HUD/SceneNumber.init(config)
	$HUD/DiceRoller.init({ 'system': self })
	$HUD/Hand.init({
		'system': self,
		'arrows': $HUD/Arrows,
		'actor_details': $HUD/ActorDetails,
	})
	$HUD/Arrows.init({ 'hand': $HUD/Hand })

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("space"):
		roll_speed_dices()

func roll_speed_dices():
	if phase == Phases.INITIAL:
		$Scenary/Actors.roll_speed_dices()
		$Music/SFX/DiceRoll.play()
		phase = Phases.PREPARATION_A
	elif phase == Phases.PREPARATION_A:
		current_team = 'left' if current_team == 'right' else 'right'
		$Music/SFX/DiceRoll.play()
		phase = Phases.PREPARATION_B

func _on_scene_presentation_timeout() -> void:
	phase = Phases.INITIAL

func createBattleEvent(attacker_dice, target_dice, card_resource):
	eventCreator.create(attacker_dice, target_dice, card_resource)
	$Music/SFX/Selected.play()

func removeBattleEvent(event, remove_by = null):
	eventCreator.remove(event, remove_by)
	$Music/SFX/Selected.play()
