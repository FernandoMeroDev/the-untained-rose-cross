extends AnimatedSprite2D

const Character = preload("res://story/narration/characters/character/character.gd")

var character: Character

var tween

## Finish Immeditely
func finish_immediately() -> void:
	if is_playing():
		stop()
		remove_vfx()

func init() -> void:
	tween = create_tween()
	positionate()
	animation_looped.connect(remove_vfx, Object.CONNECT_ONE_SHOT)
	play()
	fade_in()

## Positionate
func positionate() -> void:
	var size: Vector2 = character.sprite_frames\
		.get_frame_texture(character.animation, character.frame)\
		.get_size()
	var x: float = (size.x / 2 - 250)
	if character.flip_h:
		x = position.x - x
	else: x = position.x + x
	position = Vector2(x, position.y - (size.y / 2) + 100)

## Remove VFX
func remove_vfx() -> void:
	character.current_vfx = null
	if tween: tween.kill()
	tween = create_tween()
	tween.finished.connect(
		func(): character.remove_child(self)
	, Object.CONNECT_ONE_SHOT)
	fade_out()

## Shows with fade in Effect
func fade_in(time: float = 0.3) -> void:
	show()
	modulate.a = 0.0
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
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(
		self,
		"modulate:a",
		0.0,
		time
	)
