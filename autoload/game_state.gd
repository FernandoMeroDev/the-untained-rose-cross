extends Node

const SaveManager = preload("res://database/save_manager/save_manager.gd")

## Save Manager Instance
var save_manager: SaveManager = SaveManager.new()

## Game Config State
var config: Dictionary

## Game Story State
var story: Array

## Init Game State
func init() -> void:
	if not FileAccess.file_exists("user://config.json"):
		save_manager.save_config(
			JsonUtils.load_json("res://database/config.json")
		)
	load_config()

func create_new_game() -> void:
	save_manager.save_game({
		"story": JsonUtils.load_json("res://database/story/story.json")
	})
	load_game()

## Check if save exists
func check_save_exists() -> bool:
	return FileAccess.file_exists("user://save.json")

## Save Game State
func save_game() -> void:
	save_manager.save_game({
		"story": story
	})

## Load Game State
func load_game() -> void:
	var game_state: Dictionary = save_manager.load_game()
	story = game_state["story"]

## Save Config State
func save_config() -> void:
	save_manager.save_config(config)

## Load Config State
func load_config() -> void:
	var config_state: Dictionary = save_manager.load_config()
	config = config_state

## Set Act as Completed
func set_act_completed(
	chapter_name: String, act_name: String, victory: bool
) -> void:
	var event: Dictionary = find_story_act(chapter_name, act_name)
	event["completed"] = true
	event["content"]["results"]["victory"] = victory
	save_game()

## Find Story Act
func find_story_act(chapter_name: String, act_name: String) -> Dictionary:
	return find_story_event(chapter_name, act_name, 'act')

## Find Story Event
func find_story_event(
	chapter_name: String, event_name: String, type_name: String
) -> Dictionary:
	var result: Dictionary = {}
	for chapter in story:
		if chapter["chapter_name"] == chapter_name:
			for event in chapter["sequence"]:
				if event["type"] == type_name:
					if event["name"] == event_name:
						result = event
	return result
