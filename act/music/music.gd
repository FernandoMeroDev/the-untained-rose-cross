extends AudioStreamPlayer

## Ends smoothingly
func end_smoothingly() -> void:
	var tween := create_tween()
	tween.tween_property(self, "volume_db", -80.0, 1.0)
	tween.tween_callback(self.stop)
