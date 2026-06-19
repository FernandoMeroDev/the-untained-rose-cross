extends TextureRect

const ActorControl = preload('res://act/hud/actors/actor_control/actor_control.gd')

## Announce that this control was pressed
signal actor_control_pressed(control: ActorControl)

## Announce that mouse entered into this control
signal actor_control_mouse_entered(control: ActorControl)

## Announce that mouse exited from this control
signal actor_control_mouse_exited(control: ActorControl)

## Owner Actor ID
var actor_id: int

## Reference to owner actor
var parent_actor: Actor

func _on_box_pressed() -> void:
	actor_control_pressed.emit(self)

func _on_box_mouse_entered() -> void:
	actor_control_mouse_entered.emit(self)

func _on_box_mouse_exited() -> void:
	actor_control_mouse_exited.emit(self)

## Initialize the Actor Control
func init(actor: Actor) -> void:
	# Load Data
	actor_id = int(actor.id)
	$Portrait/Avatar.texture = load('res://media/actors/sprites/' + actor.code + '/' + 'default.png')
	$Name.text = actor.actor_name
	$HP.text = str(actor.max_hp)
	$HealthBar.max_value = actor.max_hp
	$HealthBar.value = actor.max_hp
	parent_actor = actor
	actor.actor_control = self

## Focus Actor Control
func focus() -> void:
	self_modulate = Color(1.00, 1.00, 1.00)
	$Portrait/Cover.self_modulate = Color(1.00, 1.00, 1.00)
	$Name.self_modulate = Color(0, 0.26, 1)

## Unfocus Actor Control
func unfocus() -> void:
	self_modulate = Color(0, 0, 0)
	$Portrait/Cover.self_modulate = Color(0, 0, 0)
	$Name.self_modulate = Color(1, 1, 1)

## Ourline Actor Control
func outline() -> void:
	scale = Vector2(1.1, 1.1)

## Unoutline Actor Control
func unoutline() -> void:
	scale = Vector2(1, 1)
