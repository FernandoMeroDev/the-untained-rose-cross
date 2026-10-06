class_name CardResource extends Resource

## Unique Card ID. Set in runtime.
@export var id: int

## Card Name readable for user.
@export var name: String

## Card Name readable for user.
@export var name_translations: Dictionary[String, String]

## Card Code identifier
@export var code: String

## Card cost in Light units
@export var cost: int

## Card Dices
@export var dices: Array[DiceResource]

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(
	p_id = 0,
	p_name = 'New Card',
	p_name_translations: Dictionary[String, String] = {
		'en': 'English Name',
		'es': 'Nombre en Español',
	},
	p_code = 'new_card',
	p_cost = 1,
	p_dices: Array[DiceResource] = []
): id = p_id; name = p_name ; name_translations = p_name_translations ; code = p_code; cost = p_cost; dices = p_dices
