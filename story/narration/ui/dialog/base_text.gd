extends RichTextLabel

## Emitted when finish type current text
signal typing_finished

#enum States { IDLE, WAITING_TIME, TYPING }
#
### Current status
#var status: States = States.IDLE

## Typing speed
var typing_speed: float = 20.0

## Time to await after typing
var await_after: float = 1.0

func _ready() -> void:
	set_process(false)

func type_text(locale: String, line: Dictionary) -> void:
	var content: String = line[locale]
	if line.keys().has('speed'): typing_speed = line['speed']
	if line.keys().has('await_after'): await_after = line['await_after']
	visible_characters = 0
	text = content
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
	await typing_finished
	await timeout(await_after)

## Timeout
func timeout(time: float = 1.0) -> Signal:
	return get_tree().create_timer(time).timeout
