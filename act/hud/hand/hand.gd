extends Control

const CardScene: PackedScene = preload('res://act/hud/hand/card/card.tscn')
const Card = preload('res://act/hud/hand/card/card.gd')

## Card Selected
signal card_selected(card: Card, speed_dice: SpeedDice)

signal left_card_selected(card: Card, speed_dice: SpeedDice)

signal right_card_selected(card: Card, speed_dice: SpeedDice)

## Card Deselected
signal card_deselected(card: Card)

signal left_card_deselected(card: Card)

signal right_card_deselected(card: Card)

## Enemy Speed Dice targeted
signal enemy_speed_dice_targeted(
	speed_dice: SpeedDice,
	enemy_speed_dice: SpeedDice,
	card_resource: CardResource
)

## Hand states
enum States { HIDDEN, VISIBLE, FOCUSING_DICE, CARD_SELECTED }

##  Hand current status
var status = States.HIDDEN

## Act reference
var act: Act

## Turn Manager reference
var turn_manager: TurnManager

## Gap between Cards
var gap: int = 5

## Speed Dice currently focused
var speed_dice_focused: SpeedDice

## Speed Dice currently hovered
var hovered_speed_dice: SpeedDice

## Card currently selected
var current_card_selected: Card

# --- Speed Dice Events Observers
func _on_speed_dice_pressed(speed_dice: SpeedDice) -> void:
	handle_speed_dice_pressed(speed_dice)

func _on_speed_dice_mouse_entered(speed_dice: SpeedDice) -> void:
	handle_speed_dice_mouse_entered(speed_dice)

func _on_speed_dice_mouse_exited(speed_dice: SpeedDice) -> void:
	handle_speed_dice_mouse_exited(speed_dice)

# --- Card Events Observers
func _on_card_pressed(card: Card) -> void:
	handle_card_pressed(card)
	
func _on_card_mouse_entered(card: Card) -> void:
	handle_card_mouse_entered(card)
	
func _on_card_mouse_exited(card: Card) -> void:
	handle_card_mouse_exited(card)

# --- Event Manager Events Observers
func _on_battle_event_removed(speed_dice: SpeedDice) -> void:
	handle_battle_event_removed(speed_dice)

# --- Right Click Pressed Event Handler
func handle_right_click_pressed() -> void:
	back_action()

# --- Speed Dice Events Handlers
func handle_speed_dice_pressed(speed_dice: SpeedDice) -> void:
	if(
		speed_dice.parent_actor.is_my_turn()
		and act.phase == act.Phases.PREPARATION
	):
		if status == States.VISIBLE:
			# Set Focus speed dice (Panel handles focus Styling)
			speed_dice_focused = speed_dice
			# Change Status
			status = States.FOCUSING_DICE
		elif status == States.FOCUSING_DICE:
			if speed_dice.id != speed_dice_focused.id:
				# Unset old focused speed dice (Panel handles unfocus Styling)
				speed_dice_focused = null
				# Hide Hand
				hide_hand()
				# Change focus to new speed dice
				speed_dice_focused = speed_dice
				# Show Hand
				show_hand(speed_dice.parent_actor)
			else:
				# Unset focus speed dice (Panel handles unfocus Styling)
				speed_dice_focused = null
				# Change Status
				status = States.VISIBLE
	elif(
		not speed_dice.parent_actor.is_my_turn()
		and act.phase == act.Phases.PREPARATION
	):
		if status == States.CARD_SELECTED:
			# Check if actor has enough light
			if(
				speed_dice_focused.parent_actor.can_use_card(
					current_card_selected.resource
				)
			):
				# Target enemy Speed Dice
				enemy_speed_dice_targeted.emit(
					speed_dice_focused,
					speed_dice,
					current_card_selected.resource
				)
				deselect_card()
				unfocus_dice()
			else:
				act.play_sfx('cancel')

func handle_speed_dice_mouse_entered(speed_dice: SpeedDice) -> void:
	# Set Hovered Speed Dice
	hovered_speed_dice = speed_dice
	if(
		speed_dice.parent_actor.is_my_turn()
		and act.phase == act.Phases.PREPARATION
	):
		if status == States.HIDDEN:
			# Show Hand
			show_hand(speed_dice.parent_actor)
			# Change Status
			status = States.VISIBLE

func handle_speed_dice_mouse_exited(_speed_dice: SpeedDice) -> void:
	# Unset Hovered Speed Dice
	hovered_speed_dice = null
	if status == States.VISIBLE:
		# Hide Hand
		hide_hand()
		# Change Status
		status = States.HIDDEN

# --- Card Events Handlers
func handle_card_pressed(card: Card) -> void:
	if status == States.FOCUSING_DICE:
		# Select Card
		current_card_selected = card
		# Emit Signals
		card_selected.emit(card, speed_dice_focused)
		match speed_dice_focused.parent_actor.team:
			TurnManager.Teams.LEFT:
				left_card_selected.emit(card, speed_dice_focused)
			TurnManager.Teams.RIGHT:
				right_card_selected.emit(card, speed_dice_focused)
		# Change Status
		status = States.CARD_SELECTED

func handle_card_mouse_entered(card: Card) -> void:
	if status == States.FOCUSING_DICE:
		card.focus()

func handle_card_mouse_exited(card: Card) -> void:
	if status == States.FOCUSING_DICE:
		card.unfocus()

# --- Event Manager Events Handlers
func handle_battle_event_removed(speed_dice: SpeedDice) -> void:
	speed_dice.parent_actor.refound_card_to_hand(
		speed_dice.battle_event.get_card_of_speed_dice(speed_dice)
	)
	refresh_hand(speed_dice.parent_actor)

## Reset Status
func reset_status() -> void:
	# Exit CARD_SELECTED if any
	back_action()
	# Exit FOCUSIN_DICE if any
	back_action()

## Check Hovered Speed Dice
func check_hovered_speed_dice() -> void:
	if hovered_speed_dice:
		handle_speed_dice_mouse_entered(hovered_speed_dice)

## Back Action
func back_action() -> void:
	if act.phase == act.Phases.PREPARATION:
		if status == States.FOCUSING_DICE:
			unfocus_dice()
		elif status == States.CARD_SELECTED:
			deselect_card()

## Deselect Card
func deselect_card() -> void:
	# Emit Signals
	card_deselected.emit(current_card_selected)
	match speed_dice_focused.parent_actor.team:
		TurnManager.Teams.LEFT:
			left_card_deselected.emit(current_card_selected)
		TurnManager.Teams.RIGHT:
			right_card_deselected.emit(current_card_selected)
	# Unfocus Card
	current_card_selected.unfocus()
	current_card_selected = null
	# Change status
	status = States.FOCUSING_DICE

## Unfocus Speed Dice
func unfocus_dice() -> void:
	# Unfocus speed dice (Panel handles unfocus Styling)
	speed_dice_focused = null
	# Hide Hand
	hide_hand()
	status = States.HIDDEN
	# Handle the hovered dice
	check_hovered_speed_dice()

## Show Actor Hand
func show_hand(actor: Actor) -> void:
	# Layout calculations
	var card: Card = CardScene.instantiate()
	var cards_count: int = len(actor.hand)
	var card_width: float = card.size.x
	var hand_width: float = cards_count * card_width + (cards_count - 1) * gap
	var start_x: float = (size.x - hand_width) / 2
	# Instanciate Cards
	var i: int = 0
	for card_resource: CardResource in actor.hand:
		card = CardScene.instantiate()
		card.init(
			card_resource, 
			start_x + i * (card_width + gap)
		)
		add_child(card)
		# Setup signals
		card.card_pressed.connect(_on_card_pressed)
		card.card_mouse_entered.connect(_on_card_mouse_entered)
		card.card_mouse_exited.connect(_on_card_mouse_exited)
		i += 1

## Hide current visible hand
func hide_hand() -> void:
	for card: Card in get_children():
		remove_child(card)

## Refresh Hand
func refresh_hand(actor: Actor) -> void:
	hide_hand()
	show_hand(actor)
