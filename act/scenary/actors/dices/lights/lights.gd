extends Node2D

## Parent Actor reference
var parent_actor: Actor

## Max Light
var max_light: int

## Current Light value
var value: int = 0

## Increase Max Light
func increase_max(count: int) -> void:
	value = 0
	max_light += count
	refill_max_value()

## Refill Max Value
func refill_max_value() -> void:
	remove_lights()
	add_lights(max_light)

## Add light
func add_lights(count: int) -> void:
	if value < max_light:
		remove_lights()
		value += count
		create_lights()

func sub_lights(count: int) -> void:
	remove_lights()
	value -= count
	create_lights()

## Create lights
func create_lights() -> void:
	var available: int = value
	for i: int in max_light:
		var light: TextureRect = TextureRect.new()
		match available:
			var a when a > 0:
				light.texture = preload('res://media/actors/light.png')
			var a when a <= 0:
				light.texture = preload('res://media/actors/used_light.png')
		light.scale = Vector2(0.60, 0.60)
		add_child(light)
		var gap: float = 10.00
		light.position.y -= parent_actor.get_actor_height() / 2
		light.position.y -= parent_actor.get_node('SpeedDices')\
			.get_child(0).get_rect().size.y
		light.position.y -= light.get_rect().size.y + 10
		var total_width: float = (
			(light.get_rect().size.x * max_light) + (gap * (max_light - 1))
		)
		light.position.x -= total_width / 2
		light.position.x += (light.get_rect().size.x + gap) * i
		available -= 1

## Remove Lights
func remove_lights() -> void:
	for light in get_children():
		remove_child(light)
