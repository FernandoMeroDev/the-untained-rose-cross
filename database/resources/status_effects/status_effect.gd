extends Resource

## Unique ID. Set in runtime.
@export var id: int

## Status Effect code
@export var code: String

## Stacks. Set in runtime.
@export var stacks: int

## Card Name readable for user.
@export var name: Dictionary = {
	'en': 'English name',
	'es': 'Nombre en español',
}

## Description readable for user.
@export var description: Dictionary = {
	'en': 'English description',
	'es': 'Descripción en español',
}

func _init(
	p_id: int = 0, 
	p_code: String = '',
	p_stacks: int = 0,
	p_name: Dictionary = {},
	p_description: Dictionary = {},
) -> void:
	id = p_id
	code = p_code
	stacks = p_stacks
	name = p_name
	description = p_description

## Get readable name
func get_readable_name() -> String:
	return name[GameState.config["language"]]

## Get readable stacks
func get_readable_stacks() -> String:
	return '' if stacks < 1 else str(stacks)

## Get readable description
func get_readable_description() -> String:
	return description[GameState.config["language"]]
