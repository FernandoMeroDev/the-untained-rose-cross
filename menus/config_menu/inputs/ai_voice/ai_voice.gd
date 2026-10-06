extends CheckButton

func _ready() -> void:
	button_pressed = GameState.config["ai_voices"]

func _on_toggled(toggled_on: bool) -> void:
	GameState.config["ai_voices"] = toggled_on
	GameState.save_config()
