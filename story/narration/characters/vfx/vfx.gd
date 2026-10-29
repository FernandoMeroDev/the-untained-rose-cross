extends Node2D

const Character = preload("res://story/narration/characters/character/character.gd")

var character: Character

var tween: Tween

## Finish Immeditely
func finish_immediately() -> void:
	if tween:
		tween.kill()
		remove_vfx()

## Positionate
func positionate() -> void:
	var size: Vector2 = character.sprite_frames\
		.get_frame_texture(character.animation, character.frame)\
		.get_size()
	var x: float = (size.x / 2 - 100)
	if character.flip_h:
		x = position.x - x
	else: x = position.x + x
	position = Vector2(x, position.y - (size.y / 2))

## Remove VFX
func remove_vfx() -> void:
	character.current_vfx = null
	character.remove_child(self)
