extends Node

var actor_id

var parent

func _on_box_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		parent.select_actor(actor_id)
