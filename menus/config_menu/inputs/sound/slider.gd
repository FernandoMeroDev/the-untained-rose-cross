extends HSlider

@export var bus_name: String = "Master"

func _on_drag_ended(p_value_changed: bool) -> void:
	if p_value_changed:
		var i: int = AudioServer.get_bus_index(bus_name)
		AudioServer.set_bus_volume_linear(i, value / 100)
		GameState.config["sound"][bus_name] = value
		GameState.save_config()
