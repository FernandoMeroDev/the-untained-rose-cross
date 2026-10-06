extends RichTextLabel

## Emitted when finish type current subtitle
signal typing_finished

enum States { IDLE, WAITING_TIME, TYPING }

## Subtitles status
var status: States = States.IDLE

## Movie reference
var movie: VideoStreamPlayer

## Default subtitles speed
var default_speed: float

## Locale
var locale: String

## Video Subtitles
var subtitles: Array

## Current Subtitle
var current_subtitle: Dictionary

func init(p_default_speed: float = 20) -> void:
	locale = GameState.config["language"]
	subtitles = JsonUtils.load_json(
		"res://database/story/videos/prelude_subtitles.json"
	)
	default_speed = p_default_speed
	movie.play()
	for subtitle in subtitles:
		current_subtitle = subtitle
		status = States.WAITING_TIME
		await typing_finished
	status = States.IDLE

func _process(_delta: float) -> void:
	if status == States.WAITING_TIME:
		if movie.stream_position >= current_subtitle["show_at"]:
			show_text(
				current_subtitle["content"][locale],
				current_subtitle["speed"] if(
					current_subtitle.keys().has("speed")
				) else default_speed
			)
			status = States.TYPING

## Show text
func show_text(content: String, typing_speed: float) -> void:
	text = content
	visible_characters = 0
	var duration: float = text.length() / typing_speed

	var tween: Tween = create_tween()
	tween.tween_property(
		self,
		"visible_characters",
		text.length(),
		duration
	)
	tween.finished.connect(
		func(): typing_finished.emit()
	)
