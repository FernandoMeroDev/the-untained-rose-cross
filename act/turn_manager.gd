class_name TurnManager extends RefCounted

## Act teams
enum Teams { LEFT, RIGHT }

## team in current turn
var current_team: Teams

## Randomize team
func randomize_team() -> void:
	current_team = Teams.values().pick_random()

## Toggle team
func toggle_team() -> void:
	current_team = (
		Teams.LEFT if current_team == Teams.RIGHT else Teams.RIGHT
	)

## Get readable current team
func get_readable_team() -> String:
	return (
		'Left' if current_team == Teams.LEFT else 'Right'
	)

## Checks if an Actor has current turn
func is_current_turn_of(actor: Actor) -> bool:
	return actor.team == current_team
