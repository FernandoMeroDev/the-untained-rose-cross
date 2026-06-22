class_name Act extends Node

const ActorControl = preload("res://act/hud/actors/actor_control/actor_control.gd")
const DetailsPanel = preload("res://act/hud/actor_details/panels/panel.gd")

## Act Phases
enum Phases  { 
	PRESENTATION,
	INITIAL, 
	PREPARATION,
	BATTLE 
}

## Act current Phase
var phase: Phases = Phases.PRESENTATION

## The enemy team is ready?
var enemy_team_prepared: bool = false

## Turn Manager instance
var turn_manager: TurnManager = TurnManager.new()

var eventCreator: EventCreator = EventCreator.new()

func _on_scene_presentation_timeout() -> void:
	phase = Phases.INITIAL

func _on_dice_roller_pressed() -> void:
	roll_dices()

func _input(event: InputEvent) -> void:
	# Handle input pressed space
	if event.is_action_pressed("space"):
		roll_dices()

func _ready() -> void:
	var config: Dictionary = JsonUtils.load_json('res://act/config.json')
	turn_manager.randomize_team()
	# Init ActorDetails (Panels)
	$HUD/ActorDetails.init(turn_manager)
	# Init Actors
	init_actors(config)
	# Init Scene Number
	$HUD/SceneNumber.turn_manager = turn_manager
	$HUD/SceneNumber.init(int(config['scene_number']))
	# Init Dice Roller
	init_dice_roller()
	# Init Hand
	init_hand()
	# Init Arrows
	$HUD/Arrows.init({ 'hand': $HUD/Hand })

## Init Actors, ActorControls, SpeedDices and connect them
func init_actors(config: Dictionary) -> void:
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
	# Init Actor Controls
	$HUD/Actors.init(actors)
	# Connect Actor Signals
	for actor: Actor in actors:
		# Set TurnManager reference
		actor.turn_manager = turn_manager
		# Find Actor panel
		var panel: DetailsPanel
		match actor.team:
			turn_manager.Teams.LEFT: panel = $HUD/ActorDetails/Left
			turn_manager.Teams.RIGHT: panel = $HUD/ActorDetails/Right
		# ActorN -> Panels events listeners
		actor.actor_pressed.connect(panel._on_actor_pressed)
		actor.actor_mouse_entered.connect(panel._on_actor_mouse_entered)
		actor.actor_mouse_exited.connect(panel._on_actor_mouse_exited)
		# ActorControlN -> Panels events listeners
		actor.actor_control.actor_control_pressed.connect(panel._on_actor_control_pressed)
		actor.actor_control.actor_control_mouse_entered.connect(panel._on_actor_control_mouse_entered)
		actor.actor_control.actor_control_mouse_exited.connect(panel._on_actor_control_mouse_exited)
		for speed_dice: SpeedDice in actor.get_speed_dices():
			# SpeedDiceN -> ActorDetails (Panels) events listeners
			speed_dice.speed_dice_pressed.connect(
				panel._on_speed_dice_pressed
			)
			speed_dice.speed_dice_mouse_entered.connect(
				panel._on_speed_dice_mouse_entered
			)
			speed_dice.speed_dice_mouse_exited.connect(
				panel._on_speed_dice_mouse_exited
			)
			# SpeedDiceN -> Hand events listeners
			speed_dice.speed_dice_pressed.connect(
				$HUD/Hand._on_speed_dice_pressed
			)
			speed_dice.speed_dice_mouse_entered.connect(
				$HUD/Hand._on_speed_dice_mouse_entered
			)
			speed_dice.speed_dice_mouse_exited.connect(
				$HUD/Hand._on_speed_dice_mouse_exited
			)

func init_dice_roller() -> void:
	$HUD/DiceRoller.init()
	$HUD/DiceRoller.dice_roller_pressed.connect(
		_on_dice_roller_pressed
	)

func init_hand() -> void:
	$HUD/Hand.act = self
	$HUD/Hand.turn_manager = turn_manager

## Roll Speed Dices to go next Phase
func roll_dices() -> void:
	if phase == Phases.INITIAL:
		$Scenary/Actors.roll_everyone_speed_dices()
		$Music/SFX/DiceRoll.play()
		phase = Phases.PREPARATION
	elif phase == Phases.PREPARATION:
		$Music/SFX/DiceRoll.play()
		if not enemy_team_prepared:
			turn_manager.toggle_team()
			enemy_team_prepared = true
		else:
			phase = Phases.BATTLE

func createBattleEvent(attacker_dice, target_dice, card_resource):
	eventCreator.create(attacker_dice, target_dice, card_resource)
	$Music/SFX/Selected.play()

func removeBattleEvent(event, remove_by = null):
	eventCreator.remove(event, remove_by)
	$Music/SFX/Selected.play()
