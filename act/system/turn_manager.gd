class_name TurnManager extends RefCounted

## Act teams
enum Teams { LEFT, RIGHT }

## team in current turn
var current_team: Teams

## Left team Controller reference
var left_team_controller: TeamController

## Right team Controller reference
var right_team_controller: TeamController

## Toggle team each turn?
var toggle_each_turn: bool = false

## Get lower case team name
static func get_lowercase_team(team: Teams) -> String:
	return (
		'left' if team == Teams.LEFT else 'right'
	)

## AI targets enemies
func ai_target_enemies() -> void:
	var ai_team_controller: AITeamController = get_current_controller() as AITeamController
	ai_team_controller.target_enemies()

## Is Actor controlled by AI?
func is_actor_controlled_by_ai(actor: Actor) -> bool:
	return is_team_controlled_by_ai(actor.team)
	
## Current Team is controlled by AI?
func is_current_team_controlled_by_ai() -> bool:
	var result: bool
	match current_team:
		Teams.LEFT:
			result = left_team_controller.is_controlled_by_ai()
		Teams.RIGHT:
			result = right_team_controller.is_controlled_by_ai()
	return result

## Is Team controlled by AI?
func is_team_controlled_by_ai(team: Teams) -> bool:
	var result: bool
	match team:
		Teams.LEFT:
			result = left_team_controller.is_controlled_by_ai()
		Teams.RIGHT:
			result = right_team_controller.is_controlled_by_ai()
	return result

## Get current Team Controller
func get_current_controller() -> TeamController:
	var controller: TeamController
	match current_team:
		Teams.LEFT:
			controller = left_team_controller
		Teams.RIGHT:
			controller = right_team_controller
	return controller

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
