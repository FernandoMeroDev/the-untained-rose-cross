extends Control

## Continue Game Requested
signal continue_game_requested

## New Game Requested
signal new_game_requested

func _ready() -> void:
	$Buttons/Continue.text = "MAIN_MENU_CONTINUE_GAME"
	$Buttons/NewGame.text = "MAIN_MENU_NEW_GAME"
	$Buttons/Config.text = "MAIN_MENU_CONFIG"
	$NewGameConfirmation/Background/Text.text = "MAIN_MENU_NEW_GAME_CONFIRM"
	$NewGameConfirmation/Background/Buttons/Confirm.text = "YES"
	$NewGameConfirmation/Background/Buttons/Cancel.text = "CANCEL"
	if not GameState.check_save_exists():
		$Buttons/Continue.hide()

func _on_continue_pressed() -> void:
	continue_game_requested.emit()

func _on_new_game_pressed() -> void:
	if GameState.check_save_exists():
		$NewGameConfirmation.show()
	else:
		new_game_requested.emit()

func _on_start_new_game_confirmed() -> void:
	new_game_requested.emit()

func _on_config_pressed() -> void:
	$ConfigMenu.show()

func _on_exit_config_menu_requested() -> void:
	$ConfigMenu.hide()
