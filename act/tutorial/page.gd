extends CenterContainer

signal page_mouse_pressed(page)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				page_mouse_pressed.emit(self)
