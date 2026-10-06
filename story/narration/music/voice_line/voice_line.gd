extends AudioStreamPlayer

## Narration Chapter
var narration_chapter: String

## Voice Line Request Listeners
func _on_voice_line_requested(line_id: int, delay: float = 0.0) -> void:
	await get_tree().create_timer(delay).timeout
	stream = load(
		"res://media/story/voice_lines/"
		+ narration_chapter + "/" + str(line_id) + ".mp3"
	)
	play()

## Finish inmmediately
func finish_immediately() -> void:
	if playing: stop()
