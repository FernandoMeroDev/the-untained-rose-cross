extends Control

const Dialogs = preload("res://story/narration/ui/dialog/dialogs.gd")
const OptionScene: PackedScene = preload("res://story/narration/ui/question/option.tscn")
const Option = preload("res://story/narration/ui/question/option.gd")

## Question Answered
signal question_answered

## Narration Chapter Reference.
## Example: '0_prelude_rosenklreuz/1'
var narration_chapter: String

## Dialogs Reference
var dialogs: Dialogs

## Question Code
var code: String

## Show Question
func show_question(question_data: Dictionary) -> void:
	code = question_data['code']
	var language: String = GameState.config['language']
	$VBox/TextMargin/Center/Text.text = question_data['text'][language]
	for option_data: Dictionary in question_data['options']:
		var option: Option = OptionScene.instantiate()
		option.code = option_data['code']
		option.text = option_data['text'][language]
		option.pressed.connect(
			func(): 
				answer_question(option.code)
				question_answered.emit()
		)
		$VBox/Options/HFlow.add_child(option)
	fade_in()

## Answer question
func answer_question(answer_code: String) -> void:
	save_answer(answer_code)
	for option in $VBox/Options/HFlow.get_children():
		$VBox/Options/HFlow.remove_child(option)
	fade_out()

## Save Question Answer
func save_answer(answer_code: String) -> void:
	var event: Dictionary = GameState.find_story_narration(
		narration_chapter.get_slice('/', 0),
		narration_chapter.get_slice('/', 1),
	)
	event['content']['question_answers'][code] = answer_code
	GameState.save_game()

## Shows with fade in Effect
func fade_in(time: float = 0.3) -> void:
	show()
	modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(
		self,
		"modulate:a",
		1.0,
		time
	)

## Hides with fade out Effect
func fade_out(time: float = 0.3) -> void:
	modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(
		self,
		"modulate:a",
		0.0,
		time
	)
	tween.finished.connect(func(): hide())
