extends TextureRect

const ActorControl = preload('res://act/hud/actors/actor_control/actor_control.gd')
const EmotionPoint = preload("res://act/hud/actors/actor_control/emotion_points/point.gd")

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

# Actor Events Listeners
func _on_actor_died(_actor: Actor) -> void:
	handle_actor_died()

# Actor Events Handlers
func handle_actor_died() -> void:
	disconnect_signal(actor_control_pressed)
	disconnect_signal(actor_control_mouse_entered)
	disconnect_signal(actor_control_mouse_exited)
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color("ff4040"), 0.5)

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

## Disconnect Signal
func disconnect_signal(signal_object: Signal) -> void:
	for connection: Dictionary in signal_object.get_connections():
		signal_object.disconnect(connection['callable'])

## Set curren health value
func set_health_value(value: int) -> void:
	if value < 0: value = 0
	$HP.text = str(value)
	$HealthBar.value = value

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

## Add emotion points
func add_emotion_points(points: int, type: EmotionPoint.Types) -> void:
	match type:
		EmotionPoint.Types.POSITIVE:
			$EmotionPoints.add_positive_points(points)
		EmotionPoint.Types.NEGATIVE:
			$EmotionPoints.add_negative_points(points)

## Set max emotion points
func set_max_emotion_points(count: int) -> void:
	$EmotionPoints.set_max(count)

## Set Emotion Level
func set_emotion_level(level: int) -> void:
	$EmotionLevel.set_level(level)

## Fill Emotion Points
func fill_emotion_points(type: EmotionPoint.Types) -> void:
	$EmotionPoints.fill(type)
