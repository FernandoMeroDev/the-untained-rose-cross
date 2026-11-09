# class Database/Story/.../3_NarrationConditioner
extends DefaultConditioner

const DefaultConditioner = preload("res://database/story/default_conditioner.gd")

## Previous Act story path
var previous_act_name: String = 'tutorial'

## Evaluate Condition: have player won previous act?
func have_won_previous_act() -> String:
	var story_act: Dictionary = GameState.find_story_act(
		chapter_name, previous_act_name
	)
	if story_act['content']['results']['victory']:
		return 'true'
	else: 
		return 'false'

## Evaluate Condition: Lucine repeats tutotial act?
func repeat_tutorial() -> String:
	return event['content']['question_answers']["repeat_tutorial"]
