extends Control

## Prelude finished
signal finished

## Await after
var await_after: float = 3.0

func _ready() -> void:
	$Subtitles.movie = $Movie
	$Subtitles.init()
	$Movie.finished.connect(
		func(): 
			await get_tree().create_timer(await_after).timeout
			finished.emit()
	)
