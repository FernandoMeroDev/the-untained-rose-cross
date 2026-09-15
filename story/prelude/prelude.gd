extends Control

## Prelude finished
signal finished

func _ready() -> void:
	$Subtitles.movie = $Movie
	$Subtitles.init()
	$Movie.finished.connect(
		func(): 
			await get_tree().create_timer(2.0).timeout
			finished.emit()
	)
