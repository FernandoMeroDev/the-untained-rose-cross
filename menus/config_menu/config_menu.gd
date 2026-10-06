extends Control

## Emitted on exit requested
signal exit_config_requested

func _ready() -> void:
	$Title.text = "CONFIG_MENU_TITLE"
	$Inputs/AIVoice.text = "CONFIG_MENU_AI_VOICE"
	$Inputs/Language.text = "CONFIG_MENU_LANGUAGE"
	$Inputs/Master.text = "CONFIG_MENU_MASTER_SOUND"
	$Inputs/Music.text = "CONFIG_MENU_MUSIC_SOUND"
	$Inputs/SFX.text = "CONFIG_MENU_SFX_SOUND"
	$Inputs/Voice.text = "CONFIG_MENU_VOICE_SOUND"

func _on_background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				exit_config_requested.emit()
