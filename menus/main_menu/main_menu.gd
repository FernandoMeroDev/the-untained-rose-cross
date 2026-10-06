extends Control

## Emitted when story requested
signal story_requested

func _on_start_pressed() -> void:
	story_requested.emit()

func _on_config_pressed() -> void:
	$ConfigMenu.show()

func _on_exit_config_menu_requested() -> void:
	$ConfigMenu.hide()
