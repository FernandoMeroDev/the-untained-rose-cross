extends AnimatedSprite2D

func init() -> void:
	sprite_frames = SpriteFrames.new()

## Load Expression
func load_expression(expression_name: String, texture: Texture) -> void:
	if not sprite_frames.has_animation(expression_name):
		sprite_frames.add_animation(expression_name)
	sprite_frames.add_frame(expression_name, texture)

## Change Character Expression
func change_expression(expression_name: String) -> void:
	if sprite_frames.has_animation(expression_name):
		show()
		play(expression_name)
	else:
		push_error("Character Expression not found: " + expression_name)
		hide()
