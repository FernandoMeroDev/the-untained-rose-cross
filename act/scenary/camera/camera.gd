extends Camera2D

## Camera is focused in the current event
signal zooming_finished

## Camera in its original position
signal zooming_out_finished

## Camera States
enum States { IDLE, ZOOMING_IN, ZOOMING_OUT }

## Camera current status
var status: States = States.IDLE

## Darkness reference
var darkness: ColorRect

## Current Focused Battle Event
var focused_battle_event: Event

## Strength for Camera Shake
var shake_strength: float = 0.0

func _process(delta: float) -> void:
	if status == States.ZOOMING_IN:
		var actors: Array[Actor] = focused_battle_event.get_actors()
		var actor_a: Actor = actors[0]
		var actor_b: Actor = actors[1]
		var p0: Vector2 = actor_a.position
		var p1: Vector2 = actor_b.position
		# Set camera position between the two characters
		var collision_point: Vector2 = (p0 + p1) / 2
		position = collision_point
		# Calc Zoom distance
		var distance: float = abs(p0.x - p1.x)
		# Calc Zoom: view_port_width / distance. Clamp value between [1, 2]
		var screen_width: float = get_viewport_rect().size.x
		var zoom_value = clamp(screen_width / distance, 1.0, 2.5)
		# Apply Zoom
		zoom = Vector2(zoom_value, zoom_value)
		# Check when Zoom Stops
		var a_x_position = Vector2(actor_a.global_position.x, 0)
		var a_y_position = Vector2(0, actor_a.global_position.y)
		var b_x_position = Vector2(actor_b.global_position.x, 0)
		var b_y_position = Vector2(0, actor_b.global_position.y)
		if(
			a_x_position.distance_to(b_x_position) < 100
			and a_y_position.distance_to(b_y_position) < 10
		):
			zooming_finished.emit()
			status = States.IDLE
	if status == States.ZOOMING_OUT:
		var zoom_value = clamp(zoom.x - 0.05, 1.0, 2.5)
		zoom = Vector2(zoom_value, zoom_value)
		if zoom_value == 1.0:
			zooming_out_finished.emit()
			status = States.IDLE
	# Handle Camera Shake
	if shake_strength > 0:
		# 1. reduce smoothly the shake_strength (Decay)
		shake_strength = lerp(shake_strength, 0.0, 5.0 * delta)
		# 2. Set random offset
		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		# Avoid micro-shaking
		if shake_strength < 0.1:
			shake_strength = 0
	else:
		offset = Vector2.ZERO

## Zoom into Battle Event
func zoom_into_battle_event(event: Event) -> void:
	focused_battle_event = event
	darkness.show()
	status = States.ZOOMING_IN

## Shake Camera
func shake(strength: float = 10.0) -> void:
	shake_strength = strength

## Restore Zoom value smoothingily
func reset_zoom() -> void:
	status = States.ZOOMING_OUT
	await zooming_out_finished
