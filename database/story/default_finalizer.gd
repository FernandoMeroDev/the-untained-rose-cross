# class Database/Story/DefaultFinalizer
extends RefCounted

## Narration Chapter Name
var chapter_name: String

## Request reload story after finish to go back
var request_reload_story: bool = false

## Finalize Narration
func finalize(event: Dictionary) -> void:
	event["completed"] = true
	GameState.save_game()
