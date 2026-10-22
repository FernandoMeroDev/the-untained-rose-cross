extends HFlowContainer

const StatusEffectScene: PackedScene = preload("res://act/scenary/actors/status_effects/status_effect/status_effect.tscn")
const StatusEffectResource = preload("res://database/resources/status_effects/status_effect.gd")
const StatusEffect = preload("res://act/scenary/actors/status_effects/status_effect/status_effect.gd")
const Popover = preload("res://act/hud/popovers/status_effect/status_effect.gd")

## Status Effect Popover
var popover: Popover

func set_content(resources: Array) -> void:
	clear_content()
	for resource in resources:
		var status_effect: StatusEffect = StatusEffectScene.instantiate()
		var stacks: String = resource.get_readable_stacks()
		status_effect.init( 
			resource.code,
			resource.stacks
		)
		add_child(status_effect)
		status_effect.status_effect_mouse_entered.connect(
			popover.show_popover
		)
		status_effect.status_effect_mouse_exited.connect(
			popover.hide_popover
		)

func clear_content() -> void:
	for node in get_children():
		remove_child(node)
