extends RichTextLabel

## Emitted when finish type current text
signal typing_finished

## Emitted when play a voice line is requested
signal voice_line_requested(line_id: int, delay: float)

#enum States { IDLE, WAITING_TIME, TYPING }
#
### Current status
#var status: States = States.IDLE

## Typing animation tween
var tween: Tween

## Timer
var timer: SceneTreeTimer

## Default Typing Speed
var default_typing_speed: float = 20

## Typing speed
var typing_speed: float

## Time to await after typing
var await_after: float = 1.0

func _ready() -> void:
	set_process(false)

func type_text(locale: String, line: Dictionary) -> void:
	var content: String = line[locale]
	var has_voice_line: bool = false
	if(
		line.keys().has('voice_line') 
		and GameState.config['ai_voices']
	):
		has_voice_line = true
		if line.keys().has('voice_line_delay'):
			play_voice_line(
				line['voice_line'],
				line['voice_line_delay']
			)
		else:
			play_voice_line(line['voice_line'])
	if line.keys().has('speed'):
		typing_speed = line['speed']
	else:
		typing_speed = default_typing_speed
	if line.keys().has('await_after'): await_after = line['await_after']
	visible_characters = 0
	text = content
	var duration: float = text.length() / typing_speed
	tween = create_tween()
	tween.tween_property(
		self,
		"visible_characters",
		text.length(),
		duration
	)
	tween.finished.connect(
		func(): typing_finished.emit()
	)
	if not has_voice_line:
		$Typing.play()
	await typing_finished
	$Typing.stop()
	tween = null
	create_timer(await_after)
	await timer.timeout
	timer = null

## Play Voice Line
func play_voice_line(line_id: int, delay: float = 0.0) -> void:
	voice_line_requested.emit(line_id, delay)

## Timeout
func create_timer(time: float = 1.0) -> void:
	timer = get_tree().create_timer(time)

## Finish typing immediately
func finish_immediately() -> void:
	if tween:
		tween.kill()
		visible_characters = text.length()
		typing_finished.emit()
	elif timer:
		timer.timeout.emit()
	if $Typing.playing:
		$Typing.stop()
