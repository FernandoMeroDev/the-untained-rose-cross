extends TextureRect

const ActorControl = preload("res://act/hud/actors/actor_control/actor_control.gd")

## Panel states
enum States { HIDE, VISIBLE, MOVING_UP, MOVING_DOWN, ACTOR_SELECTED }

## Panel current status
var status: States = States.HIDE

## Panel Team
var team: TurnManager.Teams

## Temporal tween
var tween: Tween

## Actor ID
var actor_id: int

## Panel original position
var original_position: Vector2

## Actor currently selected in this panel
var actor_selected: Actor

## Actor currently Hovered in this panel
var actor_hovered: Actor

func init(p_team: TurnManager.Teams) -> void:
	team = p_team
	original_position = position

# --- Right Click Pressed Event Obsever
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		handle_right_click_pressed()

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

func _on_speed_dice_mouse_entered(speed_dice: SpeedDice) -> void:
	handle_actor_mouse_entered(speed_dice.parent_actor)

func _on_speed_dice_mouse_exited(speed_dice: SpeedDice) -> void:
	handle_actor_mouse_exited(speed_dice.parent_actor)

# --- Right Click pressed Event Handler
func handle_right_click_pressed():
	if status == States.ACTOR_SELECTED:
		hide_panel(actor_selected)
		deselect_actor()
		if actor_hovered:
			handle_actor_mouse_entered(actor_hovered)

# --- Actor Events Handlers
func handle_actor_pressed(actor: Actor):
	if status == States.ACTOR_SELECTED:
		if actor_selected.id != actor.id:
			actor_selected.unfocus_self()
			actor_selected.actor_control.unfocus()
			select_actor(actor)
	else:
		select_actor(actor)

func handle_actor_mouse_entered(actor: Actor) -> void:
	actor_hovered = actor
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
	elif status == States.ACTOR_SELECTED:
		# Set Data temporally
		fill_actor_details(actor)
		# Outline Actor Control
		actor.actor_control.outline()

func handle_actor_mouse_exited(actor: Actor):
	actor_hovered = null
	if status == States.VISIBLE or status == States.MOVING_DOWN:
		hide_panel(actor)
	elif status == States.ACTOR_SELECTED:
		# Restore Data temporally overwrited
		fill_actor_details(actor_selected)
		# Unoutline Actor Control
		actor.actor_control.unoutline()

# --- Speed Dice Events Handlers
func handle_speed_dice_pressed(speed_dice: SpeedDice) -> void:
	pass

## Create Animation (Tween) Moving Down
func create_moving_down_tween() -> void:
	tween = create_tween()
	var new_position: Vector2 = original_position + Vector2(0, size.y)
	tween.tween_property(self, "position", new_position, 0.3)
	tween.finished.connect(func():
		# Prevents overwrite ACTOR_SELECTED status if user
		# selects an actor while the panel is moving down
		if status != States.ACTOR_SELECTED:
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
	actor_selected = actor
	$ActorSelected.play()
	status = States.ACTOR_SELECTED

## Deselect Actor
func deselect_actor() -> void:
	actor_selected.unfocus_self()
	actor_selected.actor_control.unfocus()
	# $ActorDeselected.play()
	actor_selected = null

## Set Actor Data
func fill_actor_details(actor: Actor):
	# Texture
	$Portrait/Actor.texture = load('res://media/actors/sprites/' + actor.code + '/default.png')
	# Resistences
	for resistence: TextureRect in $Resistences.get_children():
		var key = resistence.name.to_snake_case()
		var resistence_name = actor.resistences[key] + '_' + key # weak_pierce_damage
		resistence.tooltip_text = ''
		for word in resistence_name.split('_'):
			resistence.tooltip_text += word.capitalize() + ' '
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
	# Unoutline Actor Control
	current_actor.actor_control.unoutline()
	# Create Animation Moving Up (Tween)
	create_moving_up_tween()
	# Change Status
	status = States.MOVING_UP
