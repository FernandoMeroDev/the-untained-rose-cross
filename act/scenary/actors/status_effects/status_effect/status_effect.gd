extends TextureRect

const StatusEffectResource = preload("res://database/resources/status_effects/status_effect.gd")

## Status Effect Mouse Entered
signal status_effect_mouse_entered(
	status_effect_resource: StatusEffectResource
)

## Status Effect Mouse Exited
signal status_effect_mouse_exited

## Status Effect Resource
var resource: StatusEffectResource

func init(name_p: String, stacks_p: int) -> void:
	resource = load("res://database/resources/status_effects/" + name_p + '/' + name_p + '.tres')
	resource.stacks = stacks_p
	texture = load("res://media/act/actors/status_effects/" + name_p + ".png")
	$Stacks.text = resource.get_readable_stacks()

func _on_mouse_entered() -> void:
	status_effect_mouse_entered.emit(resource)
	scale += Vector2(0.1, 0.1)


func _on_mouse_exited() -> void:
	scale = Vector2.ONE
	status_effect_mouse_exited.emit()
