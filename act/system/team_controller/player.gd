class_name PlayerTeamController extends TeamController

func _init(p_team: TurnManager.Teams) -> void:
	type = TeamController.Types.PLAYER
	team = p_team
