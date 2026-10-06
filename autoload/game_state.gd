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
	if not FileAccess.file_exists("user://save.json"):
		save_manager.save_game({
			"story": JsonUtils.load_json("res://database/story/story.json")
		})
	load_game()

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
func set_act_completed(chapter_name: String, act_name: String) -> void:
	for chapter in story:
		if chapter["chapter_name"] == chapter_name:
			for event in chapter["sequence"]:
				if event["type"] == "act":
					if event["content"]["name"] == act_name:
						event["completed"] = true
						save_game()
