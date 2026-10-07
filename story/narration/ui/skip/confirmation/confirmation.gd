extends ColorRect

func _ready() -> void:
	$Text.text = tr("NARRATION_SKIP_CONFIRM")
	$Buttons/Cancel.text = tr("NARRATION_SKIP_CONFIR_CANCEL")
	$Buttons/Confirm.text = tr("NARRATION_SKIP_CONFIRM_YES")

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				hide()

func _on_cancel_pressed() -> void:
	hide()
