class_name TeamController extends RefCounted

enum Types { AI, PLAYER }

var type: Types

var team: TurnManager.Teams

## Is controlled by AI?
func is_controlled_by_ai() -> bool:
	return type == Types.AI
