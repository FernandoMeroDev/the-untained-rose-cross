# class DefaultFinalizer
extends RefCounted

const Actors = preload("res://act/scenary/actors/actors.gd")

## Act Reference
var act: Act

## Scenary Actors reference
var actors: Actors

func init() -> void:
	actors = act.get_node("Scenary/Actors")

## Is Act finalized?
func is_act_finalized() -> bool:
	return not actors.check_teams_can_continue()

## Get Act results
func get_act_results() -> Variant:
	return {
		"is_mortal_act": true,
		"victory": actors.check_team_can_continue(
			TurnManager.Teams.LEFT
		),
	}
