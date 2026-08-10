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

## Battle Resolver instance
var battle_resolver: BattleResolver = BattleResolver.new()

## Left team Controller instance
var left_team_controller: TeamController

## Right team Controller instance
var right_team_controller: TeamController

# --- Presentation Events Observers
func _on_scene_presentation_timeout() -> void:
	handle_scene_presentation_timeout()

# --- Dice Roller Events Observers
func _on_dice_roller_pressed() -> void:
	roll_dices()
	battle_resolver.handle_dice_roller_pressed()

func _ready() -> void:
	var config: Dictionary = JsonUtils.load_json(
		#'res://act/config.json',
		#'res://act/debug_config.json',
		#'res://act/battle_phase_config.json',
		'res://act/debug_battle_phase_config.json',
	)
	# Init Input Manager
	$InputManager.act = self
	# Init Turn Manager
	init_turn_manager(config)
	# Init ActorDetails (Panels)
	init_actor_details()
	# Init Actors
	init_actors(config)
	# Init Scene Number
	$HUD/SceneNumber.turn_manager = turn_manager
	$HUD/SceneNumber.init()
	# Init Dice Roller
	init_dice_roller()
	# Init Hand
	init_hand()
	# Init Event Creator [sytem]
	init_event_manager()
	# Init Arrows
	init_arrows()
	# Init Team Controllers
	init_team_controllers(config)
	# Init Battle Resolver
	init_battle_resolver()
	# Init Camera
	$Scenary/Camera.darkness = $Scenary/Darkness

# --- Presentation Events Handlers
func handle_scene_presentation_timeout() -> void:
	phase = Phases.UNDETERMINED_SPEED

# --- Battle Resolver Events Handlers
func handle_scene_finished() -> void:
	if $Scenary/Actors.check_teams_can_continue():
		reset_scene()
	else:
		end_act()

## Init Turn Manager
func init_turn_manager(config: Dictionary) -> void:
	if config['randomize_first_turn']:
		turn_manager.randomize_team()
	else:
		match config['first_turn_for']:
			'right':
				turn_manager.current_team = turn_manager.Teams.RIGHT
			'left':
				turn_manager.current_team = turn_manager.Teams.LEFT
	turn_manager.toggle_each_turn = config['toggle_each_turn']

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
	$HUD/Hand.left_card_selected.connect(
		$HUD/ActorDetails/Left._on_card_selected
	)
	$HUD/Hand.left_card_deselected.connect(
		$HUD/ActorDetails/Left._on_card_deselected
	)
	# Hand -> Right (panel) events listeners
	$HUD/Hand.right_card_selected.connect(
		$HUD/ActorDetails/Right._on_card_selected
	)
	$HUD/Hand.right_card_deselected.connect(
		$HUD/ActorDetails/Right._on_card_deselected
	)

## Init Event Manager
func init_event_manager() -> void:
	event_manager.act = self
	event_manager.selected_sfx = $Music/SFX/Selected
	event_manager.cancel_sfx = $Music/SFX/Cancel
	# Hand -> Event Manager events listeners
	$HUD/Hand.enemy_speed_dice_targeted.connect(
		event_manager._on_enemy_speed_dice_targeted
	)
	# Event Manager -> Hand event listeners
	event_manager.battle_event_removed.connect(
		$HUD/Hand._on_battle_event_removed
	)
	event_manager.battle_event_created.connect(
		$HUD/Hand._on_battle_event_created
	)
	# Event Manager -> Left, Right (panel) event listeners
	event_manager.battle_event_removed.connect(
		$HUD/ActorDetails/Left._on_battle_event_removed
	)
	event_manager.battle_event_removed.connect(
		$HUD/ActorDetails/Right._on_battle_event_removed
	)
	# Event Manager -> Left, Right (panel) events listeners
	event_manager.battle_event_created.connect(
		$HUD/ActorDetails/Left._on_battle_event_created
	)
	event_manager.battle_event_created.connect(
		$HUD/ActorDetails/Right._on_battle_event_created
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

## Init Team Controllers
func init_team_controllers(config: Dictionary) -> void:
	if config['controllers']['left_team'] == 'AI':
		left_team_controller = init_enemy_ai(
			TurnManager.Teams.LEFT,
			TurnManager.Teams.RIGHT,
		)
	else:
		left_team_controller = PlayerTeamController.new(
			TurnManager.Teams.LEFT
		)
	if config['controllers']['right_team'] == 'AI':
		right_team_controller = init_enemy_ai(
			TurnManager.Teams.RIGHT,
			TurnManager.Teams.LEFT
		)
	else:
		right_team_controller = PlayerTeamController.new(
			TurnManager.Teams.RIGHT
		)
	turn_manager.left_team_controller = left_team_controller
	turn_manager.right_team_controller = right_team_controller

## Init Enemy AI
func init_enemy_ai(
	team: TurnManager.Teams, enemy_team: TurnManager.Teams
) -> AITeamController:
	var ai_team_controller: AITeamController = AITeamController.new(
		team,
		$Scenary/Actors.get_team_actors(team),
		$Scenary/Actors.get_team_actors(enemy_team),
	)
	# AI Team Controller -> Event Manager Listeners
	ai_team_controller.ai_enemy_speed_dice_targeted.connect(
		event_manager._on_ai_enemy_speed_dice_targeted
	)
	return ai_team_controller

## Init Battle Resolver
func init_battle_resolver() -> void:
	# Act Reference
	battle_resolver.act = self
	# Camera reference
	battle_resolver.camera = $Scenary/Camera
	# Event Queue reference
	battle_resolver.event_queue = event_manager.event_queue
	# Actors reference
	battle_resolver.actors = $Scenary/Actors
	# Roll Dices SFX reference
	battle_resolver.dice_roll_sfx = $Music/SFX/DiceRoll
	# Battle SFX reference
	battle_resolver.battle_sfx = $Music/SFX/Battle
	# Turn Manager reference
	battle_resolver.turn_manager = turn_manager
	# Init Battle Resolver
	battle_resolver.init()

## Roll Speed Dices to go next Phase
func roll_dices() -> void:
	if phase == Phases.UNDETERMINED_SPEED:
		$Scenary/Actors.roll_everyone_speed_dices()
		$Music/SFX/DiceRoll.play()
		$HUD/ActorDetails.reset_panels_status()
		phase = Phases.PREPARATION
		$HUD/Hand.check_hovered_speed_dice()
		if turn_manager.is_current_team_controlled_by_ai():
			# IA takes first turn
			turn_manager.ai_target_enemies()
			turn_manager.toggle_team()
			enemy_team_prepared = true
			# Other IA takes second turn and battle starts
			if turn_manager.is_current_team_controlled_by_ai():
				turn_manager.ai_target_enemies()
				phase = Phases.BATTLE
				start_battle()
	elif phase == Phases.PREPARATION:
		# Player takes first/second turn
		$Music/SFX/DiceRoll.play()
		$HUD/ActorDetails.reset_panels_status()
		# Prevents show panels in battle
		get_tree().create_timer(0.5).timeout.connect(
			$HUD/ActorDetails.reset_panels_status
		)
		$HUD/Hand.reset_status()
		if not enemy_team_prepared:
			turn_manager.toggle_team()
			if turn_manager.is_current_team_controlled_by_ai():
				# IA takes second turn and starts battle
				turn_manager.ai_target_enemies()
				start_battle()
			else:
				# Other Player takes second turn
				$HUD/Hand.check_hovered_speed_dice()
				enemy_team_prepared = true
		else:
			# Player starts the Battle
			start_battle()

## Start Battle
func start_battle() -> void:
	phase = Phases.BATTLE
	# Clear any Arrow
	$Scenary/Arrows.clear_all_arrows()
	# Gives next first turn to original team
	if not turn_manager.toggle_each_turn:
		turn_manager.toggle_team()
	# Resolve Events
	battle_resolver.resolve_events()

## Reset Scene and start next
func reset_scene() -> void:
	$Scenary/Darkness.hide()
	# Repositionate Actors and show UI's elements
	$Scenary/Actors.repositionate_everyone()
	# Recover Staggered Actors
	$Scenary/Actors.recover_everyone_staggered()
	# Refill Light
	$Scenary/Actors.refill_everyone_light()
	# Restart Speed Dices
	$Scenary/Actors.restart_everyone_speed_dices()
	# Reset Camera Zoom
	await $Scenary/Camera.reset_zoom()
	# Reset enemy team prepared variable
	enemy_team_prepared = false
	# Draw card
	$Scenary/Actors.everyone_draw_cards()
	# Reiterate Act Phases
	$HUD/SceneNumber/Presentation.start()
	$HUD/SceneNumber.advance_next()
	$Scenary/Actors.show_everyone_ui_components()

## Ends Act
func end_act() -> void:
	$Scenary/Darkness.hide()
	$Music.end_smoothingly()
	# Reset Camera Zoom
	await $Scenary/Camera.reset_zoom()
	$HUD/Result.presentate_result()
