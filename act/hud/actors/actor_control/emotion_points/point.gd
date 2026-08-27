extends ColorRect

var tween: Tween

## Emotion Point Types
enum Types { POSITIVE, NEGATIVE }

## Emotion Point Type
var type: Types

## Is Emotion Point Filled?
var filled: bool = false

## Fill as posiive
func fill_as_positive() ->void:
	filled = true
	type = Types.POSITIVE
	tween = create_tween()
	tween.tween_property(self, "color", Color("38ffff"), 0.3)

## Fill as negative
func fill_as_negative() ->void:
	filled = true
	type = Types.NEGATIVE
	tween = create_tween()
	tween.tween_property(self, "color", Color("ff0038"), 0.3)
