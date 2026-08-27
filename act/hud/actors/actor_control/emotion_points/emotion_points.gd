extends HBoxContainer

const PointScene: PackedScene = preload("res://act/hud/actors/actor_control/emotion_points/point.tscn")
const Point = preload("res://act/hud/actors/actor_control/emotion_points/point.gd")
const EmotionPoint = preload("res://act/hud/actors/actor_control/emotion_points/point.gd")

func _ready() -> void:
	set_max(3)

## Set max emotion points in UI
func set_max(count: int) -> void:
	for node: Node in get_children():
		remove_child(node)
	for i in count:
		var point: Point = PointScene.instantiate()
		add_child(point)

## Add positive Emotion Points
func add_positive_points(count: int) -> void:
	for point: Point in get_children():
		if not point.filled:
			point.fill_as_positive()
			count -= 1
		if count == 0: break

## Add negative Emotion Points
func add_negative_points(count: int) -> void:
	for point: Point in get_children():
		if not point.filled:
			point.fill_as_negative()
			count -= 1
		if count == 0: break

## Fill Emotion Points
func fill(type: EmotionPoint) -> void:
	for point: Point in get_children():
		if not point.filled:
			match type:
				EmotionPoint.Types.POSITIVE:
					point.fill_as_positive()
				EmotionPoint.Types.NEGATIVE:
					point.fill_as_negative()
