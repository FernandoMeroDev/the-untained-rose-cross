class_name CardResource extends Resource

@export var id: int
@export var name: String
@export var code: String
@export var cost: int
@export var dices: Array[DiceResource]

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(
	p_id = 0,
	p_name = 'New Card',
	p_code = 'new_card',
	p_cost = 1,
	p_dices: Array[DiceResource] = []
): id = p_id; name = p_name ; code = p_code; cost = p_cost; dices = p_dices
