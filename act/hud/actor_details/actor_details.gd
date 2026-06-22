extends Control

func init(turn_manager: TurnManager):
	$Left.init(turn_manager.Teams.LEFT)
	$Right.init(turn_manager.Teams.RIGHT)
