extends AnimatedSprite2D

const SleepingVFXScene: PackedScene = preload("res://story/narration/characters/vfx/sleeping/sleeping.tscn")
const SleepingVFX = preload("res://story/narration/characters/vfx/sleeping/sleeping.gd")
const SurprisedVFXScene: PackedScene = preload("res://story/narration/characters/vfx/surprised/surprised.tscn")
const SurprisedVFX = preload("res://story/narration/characters/vfx/surprised/surprised.gd")
const HappyVFXScene: PackedScene = preload("res://story/narration/characters/vfx/happy/happy.tscn")
const HappyVFX = preload("res://story/narration/characters/vfx/happy/happy.gd")
const GloomyVFXScene: PackedScene = preload("res://story/narration/characters/vfx/gloomy/gloomy.tscn")
const GloomyVFX = preload("res://story/narration/characters/vfx/gloomy/gloomy.gd")

## Character ID
var id: String

## Character Code
var code: String

## Is character Active in the narration?
var active: bool = true

## Current VFX
var current_vfx: Variant

## Jump surprised Tween
var jumps_surprised_tween: Tween

func init(p_id: String, p_code: String) -> void:
	sprite_frames = SpriteFrames.new()
	id = p_id; code = p_code
	load_animations()

## Load Animations
func load_animations() -> void:
	$Expression.init()
	var path: String = "res://media/story/characters/" + code
	for sprite_name: String in ResourceLoader.list_directory(path):
		sprite_name = sprite_name.get_slice('/', 0)
		load_animation(
			sprite_name,
			load(path + '/' + sprite_name + '/sprite.png')
		)
		load_expressions(
			sprite_name,
			path + '/' + sprite_name,
		)

## Load Animation
func load_animation(animation_name: String, texture: Texture2D) -> void:
	if not sprite_frames.has_animation(animation_name):
		sprite_frames.add_animation(animation_name)
	sprite_frames.add_frame(animation_name, texture)

## Load Expressions
func load_expressions(animation_name: String, path: String) -> void:
	for expression_file_name: String in ResourceLoader.list_directory(path):
		if expression_file_name != 'sprite.png':
			var expression_name: String = (
				animation_name + '_' + expression_file_name.replace('.png', '')
			)
			$Expression.load_expression(
				# name format: <animation>_<expression_name>
				# name example: sleepy_open_eyes
				expression_name,
				load(path + "/" + expression_file_name)
			)
			if expression_name == 'default_default':
				$Expression.play(expression_name)

## Finish Immeditely
func finish_immediately() -> void:
	if current_vfx:
		current_vfx.finish_immediately()

## Change Character Animation
func change_animation(animation_name: String) -> void:
	animation = animation_name
	$Expression.change_expression(animation + '_default')

## Change Character Expression
func change_char_expression(expression_name: String) -> void:
	$Expression.change_expression(animation + '_' + expression_name)

## Play Char VFX
func play_vfx(vfx_name: String) -> void:
	match vfx_name:
		'sleeping':
			var sleeping_vfx: SleepingVFX = SleepingVFXScene.instantiate()
			add_child(sleeping_vfx)
			sleeping_vfx.character = self
			sleeping_vfx.init()
			current_vfx = sleeping_vfx
		'surprised':
			var surprised_vfx: SurprisedVFX = SurprisedVFXScene.instantiate()
			add_child(surprised_vfx)
			surprised_vfx.character = self
			surprised_vfx.init()
			current_vfx = surprised_vfx
		'happy':
			var happy_vfx: HappyVFX = HappyVFXScene.instantiate()
			add_child(happy_vfx)
			happy_vfx.character = self
			happy_vfx.init()
			current_vfx = happy_vfx
		'gloomy':
			var gloomy_vfx: GloomyVFX = GloomyVFXScene.instantiate()
			add_child(gloomy_vfx)
			gloomy_vfx.character = self
			gloomy_vfx.init()
			current_vfx = gloomy_vfx

## Simple Positionate Character
func simple_positionate(p_position: String) -> void:
	var texture: Vector2 = sprite_frames.get_frame_texture(animation, frame).get_size()
	var screen: Vector2 = get_viewport_rect().size
	var x: int;
	match p_position:
		'left': x = int(texture.x / 2)
		'center': x = int(screen.x / 2)
		'right': x = int(screen.x - (texture.x / 2))
	#var y: int = int(texture.y / 2 + (screen.y - texture.y))
	var y: int = int(texture.y / 2) + int(texture.y / 4)
	position = Vector2(position.x + x, position.y + y)

## Show Character
func show_character(fade_in_time: float = 0.3) -> void:
	modulate.a = 0
	show()
	var tween: Tween = create_tween()
	tween.tween_property(self, 'modulate:a', 1.0, fade_in_time)

## Flip Character Horizontally
func flip_h_char(flip: bool = true) -> void:
	flip_h = flip
	$Expression.flip_h = flip

## Activate Character
func activate_char() -> void:
	if not active:
		modulate = Color('fff')
		active = true

## Deactivate Character
func deactivate_char() -> void:
	if active:
		modulate = Color('797979')
		active = false

## Jumps in surprised
func jumps_surprised() -> void:
	var original_position: Vector2 = position
	var jump_position: Vector2 = original_position + Vector2(0, -25)
	var original_scale: Vector2 = scale
	var compressed_scale: Vector2 = Vector2(
		original_scale.x * 1.05, original_scale.y * 0.92
	)
	jumps_surprised_tween = create_tween()
	var tween: Tween = jumps_surprised_tween
	# Preparative compression
	tween.tween_property(self, "scale", compressed_scale, 0.05)
	# Jump
	tween.tween_property(
		self, "position", jump_position, 0.08
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Fall
	tween.tween_property(
		self, "position", original_position, 0.07
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# Bounce
	tween.tween_property(
		self, "position", original_position + Vector2(0, -5), 0.04
	)
	# Returns to original position
	tween.tween_property(self, "position", original_position, 0.04)
	# Returns to original scale
	tween.tween_property(self, "scale", original_scale, 0.05)
