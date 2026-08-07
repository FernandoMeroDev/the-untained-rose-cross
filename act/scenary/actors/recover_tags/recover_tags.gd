extends Control

const HealthTagScene: PackedScene = preload('res://act/scenary/actors/recover_tags/health.tscn')
const ResistTagScene: PackedScene = preload('res://act/scenary/actors/recover_tags/resist.tscn')
const RecoverTag = preload('res://act/scenary/actors/recover_tags/recover_tag.gd')

## Original Position
var original_position: Vector2

func _on_fade_animation_finished(tag) -> void:
	remove_child(tag)

# Show Healing
func show_health(value: int) -> void:
	var i: int = get_child_count()
	var health_tag: RecoverTag = HealthTagScene.instantiate() as RecoverTag
	health_tag.init(value)
	add_child(health_tag)
	health_tag.position = Vector2(
		calc_random_offset(-150),
		calc_random_offset(-80 * i)
	)
	health_tag.fade_animation_finished.connect(_on_fade_animation_finished)

# Show Recover Resist
func show_resist(value: int) -> void:
	var i: int = get_child_count()
	var resist_tag: RecoverTag = ResistTagScene.instantiate() as RecoverTag
	resist_tag.init(value)
	add_child(resist_tag)
	resist_tag.position = Vector2(
		calc_random_offset(-150),
		calc_random_offset(-80 * i)
	)
	resist_tag.fade_animation_finished.connect(_on_fade_animation_finished)

## Calc slight initial tag position variation
func calc_random_offset(offset: int, variation: int = 20) -> int:
	return randi_range(offset - variation, offset + variation)


## Flip Horizontally
func flip_h_tags(flip: bool) -> void:
	if flip:
		position.x = original_position.x + 200
	else:
		position.x = 0
