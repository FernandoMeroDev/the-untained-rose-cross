class_name Act extends Node

const DetailsPanel = preload("res://act/hud/actor_details/panels/panel.gd")

## Act Phases
enum Phases  { 
	PRESENTATION,
	UNDETERMINED_SPEED, 
	PREPARATION,
	BATTLE 
}

## Act current Phase
var phase: Phases = Phases.PRESENTATION

## The enemy team is ready?
var enemy_team_prepared: bool = false

## Turn Manager instance
var turn_manager: TurnManager = TurnManager.new()

## Event Manager instance
var event_manager: EventManager = EventManager.new()

# --- Presentation Events Observers
func _on_scene_presentation_timeout() -> void:
	phase = Phases.UNDETERMINED_SPEED

# --- Dice Roller Events Observers
func _on_dice_roller_pressed() -> void:
	roll_dices()

func _ready() -> void:
	var config: Dictionary = JsonUtils.load_json('res://act/debug_config.json')
	# Init Input Manager
	$InputManager.act = self
	# Init Turn Manager
	turn_manager.randomize_team()
	# Init ActorDetails (Panels)
	init_actor_details()
	# Init Actors
	init_actors(config)
	# Init Scene Number
	$HUD/SceneNumber.turn_manager = turn_manager
	$HUD/SceneNumber.init(int(config['scene_number']))
	# Init Dice Roller
	init_dice_roller()
	# Init Hand
	init_hand()
	# Init Event Creator [sytem]
	init_event_manager()
	# Init Arrows
	init_arrows()

## Init Actor Details (Panels)
func init_actor_details() -> void:
	$HUD/ActorDetails/Left.turn_manager = turn_manager
	$HUD/ActorDetails/Left.team = turn_manager.Teams.LEFT
	$HUD/ActorDetails/Left.act = self
	$HUD/ActorDetails/Right.turn_manager = turn_manager
	$HUD/ActorDetails/Right.team = turn_manager.Teams.RIGHT
	$HUD/ActorDetails/Right.act = self

## Init Actors, ActorControls, SpeedDices and connect them
func init_actors(config: Dictionary) -> void:
	var actors: Array[Actor] = $Scenary/Actors.init(config)
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
			# SpeedDiceN -> Event Manager events listeners
			speed_dice.speed_dice_right_click_pressed.connect(
				event_manager._on_speed_dice_right_click_pressed
			)
			# SpeedDiceN -> Arrows events listeners
			speed_dice.speed_dice_right_click_pressed.connect(
				$Scenary/Arrows._on_speed_dice_right_click_pressed
			)
			speed_dice.speed_dice_mouse_entered.connect(
				$Scenary/Arrows._on_speed_dice_mouse_entered
			)
			speed_dice.speed_dice_mouse_exited.connect(
				$Scenary/Arrows._on_speed_dice_mouse_exited
			)

## Init Dice Roller
func init_dice_roller() -> void:
	$HUD/DiceRoller.init()
	$HUD/DiceRoller.dice_roller_pressed.connect(_on_dice_roller_pressed)

## Init Hand
func init_hand() -> void:
	$HUD/Hand.act = self
	$HUD/Hand.turn_manager = turn_manager
	# Hand -> Left (panel) events listeners
	$HUD/Hand.enemy_speed_dice_targeted.connect(
		$HUD/ActorDetails/Left._on_enemy_speed_dice_targeted
	)
	$HUD/Hand.left_card_selected.connect(
		$HUD/ActorDetails/Left._on_card_selected
	)
	$HUD/Hand.left_card_deselected.connect(
		$HUD/ActorDetails/Left._on_card_deselected
	)
	# Hand -> Right (panel) events listeners
	$HUD/Hand.enemy_speed_dice_targeted.connect(
		$HUD/ActorDetails/Right._on_enemy_speed_dice_targeted
	)
	$HUD/Hand.right_card_selected.connect(
		$HUD/ActorDetails/Right._on_card_selected
	)
	$HUD/Hand.right_card_deselected.connect(
		$HUD/ActorDetails/Right._on_card_deselected
	)

## Init Event Manager
func init_event_manager() -> void:
	event_manager.selected = $Music/SFX/Selected
	# Hand -> Event Manager events listeners
	$HUD/Hand.enemy_speed_dice_targeted.connect(
		event_manager._on_enemy_speed_dice_targeted
	)
	# Event Manager -> Hand event listeners
	event_manager.battle_event_removed.connect(
		$HUD/Hand._on_battle_event_removed
	)
	# Event Manager -> Left, Right (panel) event listeners
	event_manager.battle_event_removed.connect(
		$HUD/ActorDetails/Left._on_battle_event_removed
	)
	event_manager.battle_event_removed.connect(
		$HUD/ActorDetails/Right._on_battle_event_removed
	)

## Init Arrows
func init_arrows() -> void:
	$Scenary/Arrows.left_panel = $HUD/ActorDetails/Left
	$Scenary/Arrows.right_panel = $HUD/ActorDetails/Right
	# Hand -> Arrows events listeners
	$HUD/Hand.enemy_speed_dice_targeted.connect(
		$Scenary/Arrows._on_enemy_speed_dice_targeted
	)
	$HUD/Hand.card_selected.connect($Scenary/Arrows._on_card_selected)
	$HUD/Hand.card_deselected.connect($Scenary/Arrows._on_card_deselected)
	# Panels (Left, Right) -> Arrows events listeners
	$HUD/ActorDetails/Left.speed_dice_focused_changed.connect(
		$Scenary/Arrows._on_left_panel_speed_dice_focused_changed
	)
	$HUD/ActorDetails/Right.speed_dice_focused_changed.connect(
		$Scenary/Arrows._on_right_panel_speed_dice_focused_changed
	)

## Roll Speed Dices to go next Phase
func roll_dices() -> void:
	if phase == Phases.UNDETERMINED_SPEED:
		$Scenary/Actors.roll_everyone_speed_dices()
		$Music/SFX/DiceRoll.play()
		$HUD/ActorDetails.reset_panels_status()
		phase = Phases.PREPARATION
		$HUD/Hand.check_hovered_speed_dice()
	elif phase == Phases.PREPARATION:
		$Music/SFX/DiceRoll.play()
		$HUD/ActorDetails.reset_panels_status()
		$HUD/Hand.reset_status()
		if not enemy_team_prepared:
			turn_manager.toggle_team()
			$HUD/Hand.check_hovered_speed_dice()
			enemy_team_prepared = true
		else:
			phase = Phases.BATTLE

## Play SFX
func play_sfx(sfx_name: String) -> void:
	get_node('Music/SFX/' + sfx_name.capitalize()).play()
