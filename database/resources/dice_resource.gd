class_name DiceResource extends Resource

enum Types { SLASH, PIERCE, BLUNT, BLOCK, EVADE }

@export var type: Types

@export var min_value: int

@export var max_value: int

var code: String

func _init(
	p_type = Types.SLASH,
	p_min = 1,
	p_max = 3
):
	type = p_type
	min_value = p_min
	max_value = p_max

func get_type_code() -> String:
	for type_name: String in Types:
		if Types[type_name] == type:
			return type_name.to_lower()
	Helpers.fatal_error("Dice type didn't found")
	return "";
