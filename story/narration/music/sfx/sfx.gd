extends AudioStreamPlayer

## Play SFX
func play_sfx(sfx_name: String) -> void:
	stream = load(
		"res://media/story/music/sfx/" 
		+ sfx_name + ".mp3"
	)
	play()
