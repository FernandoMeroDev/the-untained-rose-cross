class_name Game extends Node

const ActScene: PackedScene = preload("res://act/act.tscn")
const MainMenuScene: PackedScene = preload("res://menus/main_menu/main_menu.tscn")
const MainMenu = preload("res://menus/main_menu/main_menu.gd")
const StoryScene: PackedScene = preload("res://story/story.tscn")
const Story = preload("res://story/story.gd")

## Current Game Context
var current_context: Node

## Act instance
var act: Act

## Main Menu instance
var main_menu: MainMenu

## Story instance
var story: Story

## Act Listeners
func _on_act_requested(chapter_name: String, act_name: String) -> void:
	load_act(chapter_name, act_name)

func _on_act_finished(chapter_name: String, act_name: String) -> void:
	GameState.set_act_completed(chapter_name, act_name)
	load_story()

## Story Listeners
func _on_story_requested() -> void:
	load_story()

# Turn on the lights
func _ready() -> void:
	GameState.init()
	init_language()
	main_menu = MainMenuScene.instantiate()
	main_menu.story_requested.connect(_on_story_requested)
	add_child(main_menu)
	current_context = main_menu

func init_language() -> void:
	TranslationServer.set_locale(
		GameState.config["language"]
	)

##  Load Story
func load_story() -> void:
	story = StoryScene.instantiate()
	story.act_requested.connect(_on_act_requested)
	change_context(story)
	story.init()

## Load Act
func load_act(chapter_name: String, act_name: String) -> void:
	act = ActScene.instantiate()
	act.finished.connect(_on_act_finished)
	var config: Dictionary = JsonUtils.load_json(
		"res://database/acts/"
		+ chapter_name + '/' 
		+ act_name + '.json'
		# 'res://act/config.json',
		#'res://act/debug_config.json',
		#'res://act/battle_phase_config.json',
		#'res://act/debug_battle_phase_config.json',
	)
	config["chapter_name"] = chapter_name
	config["act_name"] = act_name
	change_context(act)
	act.init(config)

## Change Game Context
func change_context(context: Node) -> void:
	remove_child(current_context)
	current_context.queue_free()
	add_child(context)
	current_context = context
