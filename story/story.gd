extends Node

const PresentationScene: PackedScene = preload("res://story/presentation/presentation.tscn")
const PreludeScene: PackedScene = preload("res://story/prelude/prelude.tscn")
const ActScene: PackedScene = preload("res://act/act.tscn")
const NarrationScene: PackedScene = preload("res://story/narration/narration.tscn")

func _ready() -> void:
	# [TODO] Load story state from disk
	#await load_presentation().finished
	#unload_context()
	#await load_prelude().finished
	#unload_context()
	load_narration()
	#load_act()

func unload_context() -> void:
	for node: Node in get_children():
		remove_child(node)

func load_narration() -> Node:
	var narration: Node = NarrationScene.instantiate()
	add_child(narration)
	return narration

func load_presentation() -> Node:
	var presentation: Node = PresentationScene.instantiate()
	add_child(presentation)
	return presentation

func load_prelude() -> Node:
	var prelude: Node = PreludeScene.instantiate()
	add_child(prelude)
	return prelude

func load_act() -> Act:
	var act: Act = ActScene.instantiate()
	add_child(act)
	return act
