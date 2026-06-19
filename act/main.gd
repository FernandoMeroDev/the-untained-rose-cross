extends Node

const ActorControl = preload("res://act/hud/actors/actor_control/actor_control.gd")

enum Phases  { 
	INITIAL, 
	PREPARATION_A, 
	PREPARATION_B, 
	BATTLE 
}

var phase = null

## 'left' | 'right'
var current_team: String

var eventCreator: EventCreator

func _ready() -> void:
	eventCreator = EventCreator.new()
	var config: Dictionary = JsonUtils.load_json('res://act/config.json')
	current_team = ['left', 'right'].pick_random()
	# Init Actors
	var actors: Array[Actor] = init_actors(config)
	# Init Actor Controls
	init_actor_controls(actors)
	# Init ActorDetails
	$HUD/ActorDetails.init()
	# Init Scene Number aand Dice Roller
	$HUD/SceneNumber.init(config)
	$HUD/DiceRoller.init({ 'system': self })
	# Init Hand
	init_hand()
	# Init Arrows
	$HUD/Arrows.init({ 'hand': $HUD/Hand })

func init_actors(config: Dictionary) -> Array[Actor]:
	var actors: Array[Actor] = $Scenary/Actors.init(
		config,
		{
			'actor_details': $HUD/ActorDetails,
			'hand': $HUD/Hand,
			'arrows': $HUD/Arrows,
			'system': self,
			'sfx': { 'selected': $Music/SFX/Selected }
		}
	)
	for actor: Actor in $Scenary/Actors.get_children():
		actor.actor_pressed.connect(
			$HUD/ActorDetails._on_actor_pressed
		)
		actor.actor_mouse_entered.connect(
			$HUD/ActorDetails._on_actor_mouse_entered
		)
		actor.actor_mouse_exited.connect(
			$HUD/ActorDetails._on_actor_mouse_exited
		)
	return actors

func init_actor_controls(actors: Array[Actor]) -> void:
	$HUD/Actors.init(actors)
	for actor_control: ActorControl in $HUD/Actors.get_children():
		actor_control.actor_control_pressed.connect(
			$HUD/ActorDetails._on_actor_control_pressed
		)
		actor_control.actor_control_mouse_entered.connect(
			$HUD/ActorDetails._on_actor_control_mouse_entered
		)
		actor_control.actor_control_mouse_exited.connect(
			$HUD/ActorDetails._on_actor_control_mouse_exited
		)

func init_hand() -> void:
	$HUD/Hand.init({
		'system': self,
		'arrows': $HUD/Arrows,
		'actor_details': $HUD/ActorDetails,
	})

func _on_scene_presentation_timeout() -> void:
	phase = Phases.INITIAL

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

func createBattleEvent(attacker_dice, target_dice, card_resource):
	eventCreator.create(attacker_dice, target_dice, card_resource)
	$Music/SFX/Selected.play()

func removeBattleEvent(event, remove_by = null):
	eventCreator.remove(event, remove_by)
	$Music/SFX/Selected.play()
