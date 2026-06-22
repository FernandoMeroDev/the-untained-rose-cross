extends Control

const CardScene: PackedScene = preload('res://act/hud/hand/card/card.tscn')
const Card = preload('res://act/hud/hand/card/card.gd')

#signal card_focused(dice)
#
#signal card_unfocused()

#enum States { IDLE, DICE_FOCUSED, CARD_FOCUSED }

## Hand states
enum States { HIDDEN, VISIBLE, FOCUSING_DICE }

##  Hand current status
var status = States.HIDDEN

## Act reference
var act: Act

## Turn Manager reference
var turn_manager: TurnManager

## Gap between Cards
var gap: int = 5

## Speed Dice currently focused
var focused_speed_dice: SpeedDice

## Speed Dice currently hovered
var hovered_speed_dice: SpeedDice

## ------- OLD code down

## Is showing the hand in the screen?
var active: bool = false

## Actor currently focused
## @var Area2D | null
var focused_actor: Variant = null

## Card currently focused
## @var Button | null
var focused_card: Variant = null

## Enemy dice currently focused
## @var Node2D | null
var focused_enemy_dice: Variant = null

var card_scene: PackedScene

# --- Right Click Pressed Event Observer
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		handle_right_click_pressed()

# --- Speed Dice Events Observers
func _on_speed_dice_pressed(speed_dice: SpeedDice) -> void:
	handle_speed_dice_pressed(speed_dice)

func _on_speed_dice_mouse_entered(speed_dice: SpeedDice) -> void:
	handle_speed_dice_mouse_entered(speed_dice)

func _on_speed_dice_mouse_exited(speed_dice: SpeedDice) -> void:
	handle_speed_dice_mouse_exited(speed_dice)

# --- Right Click Pressed Event Handler
func handle_right_click_pressed() -> void:
	if(
		status == States.FOCUSING_DICE 
		and act.phase == act.Phases.PREPARATION
	):
		# Unfocus speed dice
		focused_speed_dice.unfocus()
		focused_speed_dice = null
		# Hide Hand
		hide_hand()
		status = States.HIDDEN
		# Handle the hovered dice
		if hovered_speed_dice:
			handle_speed_dice_mouse_entered(hovered_speed_dice)

# --- Speed Dice Events Handlers
func handle_speed_dice_pressed(speed_dice: SpeedDice) -> void:
	if(
		status == States.VISIBLE
		and speed_dice.parent_actor.is_my_turn()
		and act.phase == act.Phases.PREPARATION
	):
		# Focus speed dice
		speed_dice.focus()
		focused_speed_dice = speed_dice
		# Change Status
		status = States.FOCUSING_DICE
	elif(
		status == States.FOCUSING_DICE
		and speed_dice.parent_actor.is_my_turn()
		and act.phase == act.Phases.PREPARATION
	):
		if speed_dice.id == focused_speed_dice.id:
			# Unfocus speed dice
			speed_dice.unfocus()
			focused_speed_dice = null
			# Change Status
			status = States.VISIBLE
		else:
			# Unfocus old speed dice
			focused_speed_dice.unfocus()
			focused_speed_dice = null
			# Hide Hand
			hide_hand()
			# Change focus to new speed dice
			speed_dice.focus()
			focused_speed_dice = speed_dice
			# Show Hand
			show_hand(speed_dice.parent_actor)

func handle_speed_dice_mouse_entered(speed_dice: SpeedDice) -> void:
	if(
		status == States.HIDDEN 
		and speed_dice.parent_actor.is_my_turn()
		and act.phase == act.Phases.PREPARATION
	):
		# Set Hovered Speed Dice
		hovered_speed_dice = speed_dice
		# Show Hand
		show_hand(speed_dice.parent_actor)
		# Change Status
		status = States.VISIBLE

func handle_speed_dice_mouse_exited(_speed_dice: SpeedDice) -> void:
	if status == States.VISIBLE:
		# Unset Hovered Speed Dice
		hovered_speed_dice = null
		# Hide Hand
		hide_hand()
		# Change Status
		status = States.HIDDEN

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
		i += 1

## Hide current visible hand
func hide_hand() -> void:
	for card: Card in get_children():
		remove_child(card)
