extends Label


## Number original position
var original_position: Vector2

## Animation (Tween) shaking number
var animation_shaking: Tween

func init(min_value: int, max_value: int) -> void:
	set_value_interval(min_value, max_value)
	original_position = position
	animate_shaking()

func set_value_interval(min_value: int, max_value: int) -> void:
	text = str(min_value) + '~' + str(max_value)

func set_value(n: int) -> void:
	text = str(n)

func animate_shaking(duration: float = 1.8, strength: float = 8.0) -> void:
	animation_shaking = create_tween()
	animation_shaking.set_trans(Tween.TRANS_SINE)
	animation_shaking.set_ease(Tween.EASE_IN_OUT)
	var steps = 6
	for i in steps:
		var offset = Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		animation_shaking.tween_property(self, "position", original_position + offset, duration / steps)
	animation_shaking.tween_property(self, "position", original_position, duration / steps)
	animation_shaking.set_loops()

func stop_animation_shaking():
	animation_shaking.kill()
	position = original_position
