extends Control

## Emitted on exit requested
signal exit_pause_requested

## Return to start screen requested
signal return_to_start_requested

func _ready() -> void:
	$Inputs/ReturnToStart.text = "PAUSE_MENU_RETURN_TO_START"
	$Inputs/AIVoice.text = "CONFIG_MENU_AI_VOICE"
	$Inputs/Master.text = "CONFIG_MENU_MASTER_SOUND"
	$Inputs/Music.text = "CONFIG_MENU_MUSIC_SOUND"
	$Inputs/SFX.text = "CONFIG_MENU_SFX_SOUND"
	$Inputs/Voice.text = "CONFIG_MENU_VOICE_SOUND"

func _on_background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				exit_pause_requested.emit()


func _on_return_to_start_pressed() -> void:
	play()
	return_to_start_requested.emit()

## Pause
func pause() -> void:
	show()
	get_tree().paused = true

## Play
func play() -> void:
	get_tree().paused = false
	hide()
