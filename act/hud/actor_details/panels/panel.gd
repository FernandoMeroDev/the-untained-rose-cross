extends TextureRect

const ActorControl = preload("res://act/hud/actors/actor_control/actor_control.gd")
const Card = preload('res://act/hud/hand/card/card.gd')

signal speed_dice_focused_changed(speed_dice: SpeedDice)

## Panel states
enum States { HIDE, VISIBLE, MOVING_UP, MOVING_DOWN, ACTOR_FOCUSED }

## Panel current status
var status: States = States.HIDE

## Act reference
var act: Act

## Turn Manager reference
var turn_manager: TurnManager

## Panel's Team
var team: TurnManager.Teams

## Temporal tween
var tween: Tween

## Actor ID
var actor_id: int

## Panel original position
var original_position: Vector2

## Actor currently selected in this panel
var actor_focused: Actor

## Actor currently Hovered in this panel
var actor_hovered: Actor

## Speed Dice currently selected in this panel
var speed_dice_focused: SpeedDice

## Speed Dice currently Hovered in this panel
var speed_dice_hovered: SpeedDice

## Used to block the panel when the hand is selecting a Card
var panel_blocked: bool = false

func _ready():
	original_position = position

# --- Actor Events Observers
func _on_actor_pressed(actor: Actor) -> void:
	handle_actor_pressed(actor)

func _on_actor_mouse_entered(actor: Actor) -> void:
	handle_actor_mouse_entered(actor)

func _on_actor_mouse_exited(actor: Actor) -> void:
	handle_actor_mouse_exited(actor)

# --- Actor Control Events Observers
func _on_actor_control_pressed(control: ActorControl) -> void:
	handle_actor_pressed(control.parent_actor)

func _on_actor_control_mouse_entered(control: ActorControl) -> void:
	handle_actor_mouse_entered(control.parent_actor)

func _on_actor_control_mouse_exited(control: ActorControl) -> void:
	handle_actor_mouse_exited(control.parent_actor)

# --- Actor Speed Dices Events Observers
func _on_speed_dice_pressed(speed_dice: SpeedDice) -> void:
	handle_actor_pressed(speed_dice.parent_actor)
	handle_speed_dice_pressed(speed_dice)

func _on_speed_dice_mouse_entered(speed_dice: SpeedDice) -> void:
	handle_actor_mouse_entered(speed_dice.parent_actor)
	handle_speed_dice_mouse_entered(speed_dice)

func _on_speed_dice_mouse_exited(speed_dice: SpeedDice) -> void:
	handle_actor_mouse_exited(speed_dice.parent_actor)
	handle_speed_dice_mouse_exited(speed_dice)

# --- Hand Events Observers
func _on_card_selected(card: Card, _speed_dice: SpeedDice) -> void:
	handle_card_selected(card)

func _on_card_deselected(card: Card) -> void:
	handle_card_deselected(card)

# --- Event Manager Events Observers
func _on_battle_event_created(battle_event: Event) -> void:
	handle_battle_event_created(battle_event)

func _on_battle_event_removed(speed_dice: SpeedDice) -> void:
	handle_battle_event_removed(speed_dice)

# --- Right Click pressed Event Handler
func handle_right_click_pressed():
	# Exit if panel is blocked
	if panel_blocked: return
	reset_status()

# --- Hand Events Handlers
func handle_card_selected(card: Card) -> void:
	panel_blocked = true
	clear_card()
	load_card_resource(card.resource)

func handle_card_deselected(_card: Card) -> void:
	panel_blocked = false
	clear_card()
	if speed_dice_hovered:
		if speed_dice_hovered.battle_event:
			load_card_from_speed_dice(speed_dice_hovered)
	elif speed_dice_focused:
		if speed_dice_focused.battle_event:
			load_card_from_speed_dice(speed_dice_focused)

# --- Actor Events Handlers
func handle_actor_pressed(actor: Actor):
	# Exit if panel is blocked
	if panel_blocked: return
	if act.phase != act.Phases.BATTLE:
		if status == States.ACTOR_FOCUSED:
			if actor_focused.id != actor.id:
				actor_focused.unfocus_self()
				actor_focused.actor_control.unfocus()
				select_actor(actor)
		else:
			select_actor(actor)

func handle_actor_mouse_entered(actor: Actor) -> void:
	actor_hovered = actor
	if act.phase != act.Phases.BATTLE:
		if status == States.HIDE:
			if tween: tween.kill()
			# Set Data
			fill_actor_details(actor)
			# Outline Actor Control
			actor.actor_control.outline()
			# Create Animation Moving Down (Tween)
			create_moving_down_tween()
			# Change Status
			status = States.MOVING_DOWN
		elif status == States.MOVING_UP or status == States.MOVING_DOWN:
			if tween: tween.kill()
			# Set Data
			fill_actor_details(actor)
			# Outline Actor Control
			actor.actor_control.outline()
			# Set Position
			position = original_position + Vector2(0, size.y)
			# Change Status
			status = States.VISIBLE
		elif status == States.ACTOR_FOCUSED:
			# Set Data temporally
			fill_actor_details(actor)
			# Outline Actor Control
			actor.actor_control.outline()

func handle_actor_mouse_exited(actor: Actor):
	actor_hovered = null
	if act.phase != act.Phases.BATTLE:
		if status == States.VISIBLE or status == States.MOVING_DOWN:
			hide_panel(actor)
		elif status == States.ACTOR_FOCUSED:
			# Restore Data temporally overwrited
			fill_actor_details(actor_focused)
			# Unoutline Actor Control
			actor.actor_control.unoutline()

# --- Speed Dice Events Handlers
func handle_speed_dice_pressed(speed_dice: SpeedDice) -> void:
	# Exit if panel is blocked
	if panel_blocked: return
	if(
		act.phase == act.Phases.PREPARATION 
		and not speed_dice.parent_actor.staggered
	):
		if not speed_dice_focused:
			# Focus speed dice
			speed_dice.focus()
			speed_dice_focused = speed_dice
		else:
			if speed_dice.id != speed_dice_focused.id:
				# Unfocus old speed dice
				speed_dice_focused.unfocus()
				# Focus new speed dice
				speed_dice.focus()
				# Emit signal
				speed_dice_focused_changed.emit(speed_dice)
				# Clear Old Card
				clear_card()
				# Load new Card
				if speed_dice.battle_event:
					load_card_from_speed_dice(speed_dice)
				# Change Status
				speed_dice_focused = speed_dice
			else:
				# Unfocus speed dice
				speed_dice_focused.unfocus()
				speed_dice_focused = null

func handle_speed_dice_mouse_entered(speed_dice: SpeedDice) -> void:
	speed_dice_hovered = speed_dice
	# Exit if panel is blocked
	if panel_blocked: return
	clear_card()
	if speed_dice.battle_event:
		load_card_from_speed_dice(speed_dice)

func handle_speed_dice_mouse_exited(speed_dice: SpeedDice) -> void:
	speed_dice_hovered = null
	# Exit if panel is blocked
	if panel_blocked: return
	if speed_dice_focused:
		if speed_dice_focused.id != speed_dice.id:
			clear_card()
			if speed_dice_focused.battle_event:
				load_card_from_speed_dice(speed_dice_focused)
	else:
		if speed_dice.battle_event:
			clear_card()

# --- Event Manager Events Handlers
func handle_battle_event_removed(speed_dice: SpeedDice) -> void:
	if speed_dice.parent_actor.team == team:
		clear_card()

func handle_battle_event_created(_battle_event: Event) -> void:
	# Handle Actor Status
	if status == States.ACTOR_FOCUSED:
		unfocus_actor()
	# Handle Focused Speed Dice
	if speed_dice_focused:
		# Unfocus speed dice
		speed_dice_focused.unfocus()
		speed_dice_focused = null

## Reset Status
func reset_status() -> void:
	# Handle Actor Status
	if status == States.ACTOR_FOCUSED:
		unfocus_actor()
	elif status == States.VISIBLE or status == States.MOVING_DOWN:
		hide_panel(null)
	# Handle Actor Hovered
	if actor_hovered:
		handle_actor_mouse_entered(actor_hovered)
	# Handle Focused Speed Dice
	if speed_dice_focused:
		# Unfocus speed dice
		speed_dice_focused.unfocus()
		speed_dice_focused = null

## Unfocus Actor
func unfocus_actor() -> void:
	hide_panel(actor_focused)
	deselect_actor()
	if actor_hovered:
		handle_actor_mouse_entered(actor_hovered)

## Create Animation (Tween) Moving Down
func create_moving_down_tween() -> void:
	tween = create_tween()
	var new_position: Vector2 = original_position + Vector2(0, size.y)
	tween.tween_property(self, "position", new_position, 0.3)
	tween.finished.connect(func():
		# Prevents overwrite ACTOR_SELECTED status if user
		# selects an actor while the panel is moving down
		if status != States.ACTOR_FOCUSED:
			status = States.VISIBLE
	)

## Create Animation (Tween) Moving Up
func create_moving_up_tween() -> void:
	tween = create_tween()
	var new_position: Vector2 = original_position - Vector2(0, size.y)
	tween.tween_property(self, "position", new_position, 0.3)
	tween.finished.connect(func():
		status = States.HIDE
	)

## Select Actor
func select_actor(actor: Actor):
	actor.focus_self()
	actor.actor_control.focus()
	actor_focused = actor
	$ActorSelected.play()
	status = States.ACTOR_FOCUSED

## Deselect Actor
func deselect_actor() -> void:
	actor_focused.unfocus_self()
	actor_focused.actor_control.unfocus()
	# $ActorDeselected.play()
	actor_focused = null

## Set Actor Data
func fill_actor_details(actor: Actor):
	# Texture
	$Portrait/Actor.texture = load('res://media/actors/sprites/' + actor.code + '/default.png')
	# Resistences
	for resistence: TextureRect in $Resistences.get_children():
		var key: String = resistence.name.to_snake_case()
		var resistence_name: String = actor.resistences[key] + '_' + key # weak_pierce_damage
		#resistence.tooltip_text = ''
		#for word in resistence_name.split('_'):
			#resistence.tooltip_text += word.capitalize() + ' '
		resistence.tooltip_text = tr(
			'ACT_RESISTENCE_'
			+ resistence_name.to_upper()
		)
		resistence.texture = load('res://media/icons/resistences/' + resistence_name + '.png')
	# Name
	$Name/Text.text = actor.actor_name
	# HP Gauge
	$Gauges/Health.max_value = actor.max_hp
	$Gauges/Health.value = actor.hp
	$Gauges/Health/Number.text = str(actor.hp)
	# RP Gauge
	$Gauges/Resist.max_value = actor.max_resist
	$Gauges/Resist.value = actor.resist
	$Gauges/Resist/Number.text = str(actor.resist)

## Hide panel
func hide_panel(current_actor: Actor) -> void:
	if tween: tween.kill()
	if current_actor:
		# Unoutline Actor Control
		current_actor.actor_control.unoutline()
	# Create Animation Moving Up (Tween)
	create_moving_up_tween()
	# Change Status
	status = States.MOVING_UP

## Load Card Resource from dice
func load_card_from_speed_dice(speed_dice: SpeedDice) -> void:
	load_card_resource(
		speed_dice.battle_event.get_card_of_speed_dice(speed_dice)
	)

## Load Card Resource
func load_card_resource(card_resource: CardResource) -> void:
	$Card.load_card_resource(card_resource)
	$Card.show()

## Clear Card and hide
func clear_card() -> void:
	$Card.unload_card_resource()
	$Card.hide()
