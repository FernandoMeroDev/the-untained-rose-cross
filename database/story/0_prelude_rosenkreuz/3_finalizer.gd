# class Database/Story/.../3_NarrationFinalizer
extends DefaultFinalizer

const DefaultFinalizer = preload("res://database/story/default_finalizer.gd")

## Previous Act story path
var previous_act_name: String = 'tutorial'

func _init() -> void:
	request_reload_story = true

## Finalize Narration
func finalize(event: Dictionary) -> void:
	var answer: String = event["content"]['question_answers']['repeat_tutorial']
	match answer:
		'repeat':
			var story_act: Dictionary = GameState.find_story_act(chapter_name, previous_act_name)
			story_act['completed'] = false
		'no-repeat':
			event['completed'] = true
	GameState.save_game()
