extends TextureRect

const ActorControl = preload('res://act/hud/actors/actor_control/actor_control.gd')

## Announce that this control was pressed
signal actor_control_pressed(control: ActorControl)

signal actor_control_mouse_entered(control: ActorControl)

signal actor_control_mouse_exited(control: ActorControl)

## Owner Actor ID
var actor_id: int

func _on_box_pressed() -> void:
	actor_control_pressed.emit(self)

func _on_box_mouse_entered() -> void:
	actor_control_mouse_entered.emit(self)

func _on_box_mouse_exited() -> void:
	actor_control_mouse_exited.emit(self)

## Initialize the Actor Control
func init(actor_data: Dictionary) -> void:
	var max_hp: int = int(actor_data['stats']['max_hp'])
	# Load Data
	actor_id = int(actor_data['id'])
	$Portrait/Avatar.texture = load('res://media/actors/sprites/' + actor_data['code'] + '/' + 'default.png')
	$Name.text = actor_data['name']
	$HP.text = str(max_hp)
	$HealthBar.max_value = max_hp
	$HealthBar.value = max_hp

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
