extends Camera2D

## Camera States
enum States { IDLE, ZOOMING_IN }

## Camera current status
var status: States = States.IDLE

## Darkness reference
var darkness: ColorRect

## Current Focused Battle Event
var focused_battle_event: Event

func _process(_delta: float) -> void:
	if status == States.ZOOMING_IN:
		var actors: Array[Actor] = focused_battle_event.get_actors()
		var actor_a: Actor = actors[0]
		var actor_b: Actor = actors[1]
		actor_a.z_index = 1000
		actor_b.z_index = 1000
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
		if(
			actor_a.global_position.distance_to(actor_b.global_position) 
			< 100
		):
			status = States.IDLE

## Zoom into Battle Event
func zoom_into_battle_event(event: Event) -> void:
	focused_battle_event = event
	darkness.show()
	status = States.ZOOMING_IN
