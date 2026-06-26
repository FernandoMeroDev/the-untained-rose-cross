extends Control

## Reset both Panels status
func reset_panels_status() -> void:
	$Left.reset_status()
	$Right.reset_status()
