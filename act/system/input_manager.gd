extends Node

## Act reference
var act: Act

# --- Right Click Pressed Event Observer
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("space"):
		act.roll_dices()
	if event.is_action_pressed("right_click"):
		act.get_node("Scenary/Arrows").handle_right_click_pressed()
		act.get_node("HUD/ActorDetails/Left").handle_right_click_pressed()
		act.get_node("HUD/ActorDetails/Right").handle_right_click_pressed()
		act.get_node("HUD/Hand").handle_right_click_pressed()
