extends Control

## Open Menu Requested
signal open_pause_menu_requested

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			open_pause_menu_requested.emit()
