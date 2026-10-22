extends Control

const StatusEffectResource = preload("res://database/resources/status_effects/status_effect.gd")

## Show popover
func show_popover(resource: StatusEffectResource) -> void:
	var label = $Description/MarginContainer/VBox/Name
	var description = $Description/MarginContainer/VBox/Text
	var effect_name: String = resource.get_readable_name()
	var stacks: String = resource.get_readable_stacks()
	label.text = stacks + ' ' + effect_name
	description.text = resource.get_readable_description()
	var viewport_rect: Rect2 = get_viewport_rect()
	show()
	# Set the global position temporally hidden
	# and await gotod to process the UI draw
	global_position = viewport_rect.end
	await get_tree().create_timer(0.1).timeout
	# Positionate the popover
	positionate_self()

## Hide popover
func hide_popover() -> void:
	hide()

## Positionate popover
func positionate_self() -> void:
	var target_position: Vector2 = get_global_mouse_position()
	var final_position: Vector2 = target_position
	var viewport_rect: Rect2 = get_viewport_rect()
	var popover_size: Vector2 = $Description.size
	if (final_position.x + popover_size.x) > viewport_rect.end.x:
		final_position.x = target_position.x - popover_size.x
	if (final_position.y + popover_size.y) > viewport_rect.end.y:
		final_position.y = target_position.y - popover_size.y
	#final_position.x = maxf(final_position.x, viewport_rect.position.x)
	#final_position.y = maxf(final_position.y, viewport_rect.position.y)
	global_position = final_position
