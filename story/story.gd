extends Node

const PresentationScene: PackedScene = preload("res://story/presentation/presentation.tscn")
const PreludeScene: PackedScene = preload("res://story/videos/prelude/prelude.tscn")
const ActScene: PackedScene = preload("res://act/act.tscn")
const NarrationScene: PackedScene = preload("res://story/narration/narration.tscn")
const Narration = preload("res://story/narration/narration.gd")

## Return to start requested
signal return_to_start_requested

## Emitted when an Act is requested in the story
signal act_requested(chapter_name: String, act_name: String)

## Reload Story Request for go back
signal reload_story_requested

## Current Story Context
var current_context: Node

func init() -> void:
	var story_state: Array = GameState.story
	for chapter: Dictionary in story_state:
		var chapter_name: String = chapter["chapter_name"]
		for event: Dictionary in chapter["sequence"]:
			if event["completed"]: continue
			match event["type"]:
				"presentation":
					load_presentation(
						event["content"]["text"]
					)
				"video":
					load_video(event["content"]["video_id"])
				"narration":
					load_narration(chapter_name, event)
				"act":
					act_requested.emit(
						chapter_name, event["name"]
					)
					break
			await current_context.finished
			if current_context.get('finalizer'):
				current_context.finalizer.finalize(event)
				if current_context.finalizer.request_reload_story:
					reload_story_requested.emit()
					break
			else:
				event["completed"] = true
				GameState.save_game()
			unload_context()

## Load Narration
func load_narration(chapter_name: String, event: Dictionary) -> void:
	var narration_name: String = event["name"]
	var narration_id: String = chapter_name + "/" + narration_name
	var narration_data: Variant = JsonUtils.load_json(
		"res://database/story/" + narration_id + ".json"
	)
	var narration: Narration = NarrationScene.instantiate()
	narration.return_to_start_requested.connect(
		func(): return_to_start_requested.emit()
	)
	add_child(narration)
	narration.event = event
	narration.init(narration_id, narration_data)
	current_context = narration

## Load Video
func load_video(video_id: String) -> void:
	if video_id == "prelude":
		var prelude: Node = PreludeScene.instantiate()
		add_child(prelude)
		current_context = prelude

## Load Presentation
func load_presentation(text: Dictionary) -> void:
	var presentation: Node = PresentationScene.instantiate()
	add_child(presentation)
	presentation.init(text)
	current_context = presentation

## Unload Context
func unload_context() -> void:
	remove_child(current_context)
	current_context.queue_free()
	current_context = null
