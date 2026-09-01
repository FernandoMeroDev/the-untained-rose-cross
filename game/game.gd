class_name Game extends Node

const ActScene: PackedScene = preload("res://act/act.tscn")
const MainMenuScene: PackedScene = preload("res://main_menu/main_menu.tscn")
const StoryScene: PackedScene = preload("res://story/story.tscn")

## Current Game Context
var current_context: Node

## Act instance
var act: Act

## Main Menu instance
var main_menu: Control

## Story instance
var story: Control

# Turn on the lights
func _ready() -> void:
	main_menu = MainMenuScene.instantiate()
	main_menu.game = self
	add_child(main_menu)
	current_context = main_menu

## Change Game Context
func change_context(context: Node) -> void:
	remove_child(current_context)
	current_context.queue_free()
	add_child(context)
	current_context = context

##  Start Story
func start_story() -> void:
	story = StoryScene.instantiate()
	change_context(story)
