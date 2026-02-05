extends Node

enum Phases  { INITIAL, PREPARATION, BATTLE }

var phase = null

func _ready() -> void:
	var config = JsonUtils.load_json('res://act/config.json')
	$Scenary/Actors.init(
		config,
		{
			'actor_details': $HUD/ActorDetails
		}
	)
	$HUD/ActorDetails.init($Scenary/Actors)
	$HUD/Actors.init(
		config,
		{
			'actor_details': $HUD/ActorDetails
		}
	)
	$HUD/SceneNumber.init(config)
	$HUD/DiceRoller.init(self)

func _on_scene_presentation_timeout() -> void:
	phase = Phases.INITIAL

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("space"):
		roll_speed_dices()

func roll_speed_dices():
	if phase == Phases.INITIAL:
		phase = Phases.PREPARATION
		$Scenary/Actors.roll_speed_dices()
		$Music/DiceRoll.play()
