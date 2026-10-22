extends Control

var original_scale

var new_scale

var scale_factor = 0.1

func _ready() -> void:
	pivot_offset = Vector2(
		size.x / 2,
		size.y / 2,
	)
	original_scale = scale
	new_scale = original_scale + Vector2(scale_factor, scale_factor)
	var tween = create_tween()
	tween.set_parallel().tween_property(self, 'scale', new_scale, 1.0)
	tween.chain().tween_property(self, 'scale', original_scale, 1.0)
	tween.set_loops()
	
	
