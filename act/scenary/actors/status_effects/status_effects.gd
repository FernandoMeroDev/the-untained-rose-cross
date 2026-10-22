extends HFlowContainer

const StatusEffectScene: PackedScene = preload("res://act/scenary/actors/status_effects/status_effect/status_effect.tscn")
const StatusEffect = preload("res://act/scenary/actors/status_effects/status_effect/status_effect.gd")
const StatusEffectResource = preload("res://database/resources/status_effects/status_effect.gd")
const Popover = preload("res://act/hud/popovers/status_effect/status_effect.gd")

## Status Effect Popover
var popover: Popover

## Counts Unique IDs in runtime for Status Effects in Actor
var id_count: int = 0

func init(status_effects_data: Array) -> void:
	for effect_data in status_effects_data:
		var status_effect: StatusEffect = StatusEffectScene.instantiate()
		status_effect.init(effect_data['name'], effect_data['stacks'])
		add(status_effect)

## Add new Status Effect
func add(status_effect: StatusEffect) -> void:
	id_count += 1
	status_effect.resource.id = id_count
	add_child(status_effect)
	# Connect signals
	status_effect.status_effect_mouse_entered.connect(
		popover.show_popover
	)
	status_effect.status_effect_mouse_exited.connect(
		popover.hide_popover
	)
	

## Alter physical damage
func alter_physical_damage(damage: int) -> int:
	for status_effect in get_children():
		var resource: StatusEffectResource = status_effect.resource
		if resource.has_method('alter_physical_damage'):
			damage = resource.alter_physical_damage(damage)
	return damage

## Alter stagger damage
func alter_stagger_damage(damage: int) -> int:
	for status_effect in get_children():
		var resource: StatusEffectResource = status_effect.resource
		if resource.has_method('alter_stagger_damage'):
			damage = resource.alter_stagger_damage(damage)
	return damage
