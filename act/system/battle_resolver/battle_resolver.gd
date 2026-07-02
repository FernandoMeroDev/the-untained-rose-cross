class_name BattleResolver extends RefCounted

const Camera = preload("res://act/scenary/camera/camera.gd")

## Camera reference
var camera: Camera

## Event Queue reference
var event_queue: EventQueue

## Current Battle Event
var current_event: Event

## Resolve Event Queue
func resolve_events() -> void:
	# Order Event Queue
	event_queue.order_by_speed()
	# Log Events for Debug
	#event_queue.log_in_console()
	# Check for if any event
	if event_queue.size() > 0:
		current_event = event_queue.events[0]
	# Resolve Event
	if current_event:
		# Zoom into current Event
		camera.zoom_into_battle_event(current_event)
