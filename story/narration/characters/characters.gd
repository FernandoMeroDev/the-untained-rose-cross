extends Node2D

const CharacterScene: PackedScene = preload("res://story/narration/characters/character/character.tscn")
const Character = preload("res://story/narration/characters/character/character.gd")

## Everyone Finish Immediately
func everyone_finish_immediately() -> void:
	for node in get_children():
		if node is Character:
			node.finish_immediately()

## Add Character
func add_character(id: String, code: String) -> void:
	var character: Character = CharacterScene.instantiate()
	character.init(id, code)
	add_child(character)

## Show Character
func show_char(id: String, fade_in_time: float = 0.3) -> void:
	find_character(id).show_character(fade_in_time)

## Activate Character
func activate_char(id: String) -> void:
	find_character(id).activate_char()

## Deactivate Character
func deactivate_char(id: String) -> void:
	find_character(id).deactivate_char()

## Change Character Animation
func change_char_animation(id: String, animation_name: String) -> void:
	find_character(id).change_animation(animation_name)

## Change Character Expression
func change_char_expression(id: String, expression_name: String) -> void:
	find_character(id).change_char_expression(expression_name)

## Play Char VFX
func play_char_vfx(id: String, vfx_name: String) -> void:
	find_character(id).play_vfx(vfx_name)

## Positionate Character
func positionate_char(id: String, p_position: Array) -> void:
	find_character(id).position = Vector2(p_position[0], p_position[1])

## Simple Positionate Character
func simple_positionate_char(id: String, p_position: String) -> void:
	find_character(id).simple_positionate(p_position)

## Flip Horizontally Character
func flip_h_char(id: String, flip: bool = true) -> void:
	find_character(id).flip_h_char(flip)

## Find Character
func find_character(id: String) -> Character:
	var character: Character
	for node in get_children():
		if node is Character:
			if node.id == id:
				character = node
	return character
