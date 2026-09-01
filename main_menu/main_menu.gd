extends Control

## Game reference
var game: Game

func _on_start_pressed() -> void:
	game.start_story()
