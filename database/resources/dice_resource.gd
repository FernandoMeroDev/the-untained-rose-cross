class_name DiceResource extends Resource

enum Types { SLASH, PIERCE, BLUNT, BLOCK, EVADE }

@export var type: Types

@export var min_value: int

@export var max_value: int

func _init(
	p_type = Types.SLASH,
	p_min = 1,
	p_max = 3
):
	type = p_type
	min_value = p_min
	max_value = p_max

## Get Dice Type code.
## For example: slash | blunt | pierce | block | evade
func get_type_code() -> String:
	var result: String
	for type_name: String in Types:
		if Types[type_name] == type:
			result = type_name.to_lower()
	return result;
