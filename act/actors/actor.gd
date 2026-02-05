extends Node2D

var team

var id; var code

var actor_name

var max_hp; var max_resist

var hp; var resist

var speed

var max_light

var status_effects

var resistences

var dependencies = {}

func _ready():
	$CollisionShape.shape = $CollisionShape.shape.duplicate()

func init(actor_data, actor_dependencies):
	team = actor_data['team']
	id = int(actor_data['id']); code = actor_data['code']
	actor_name = actor_data["name"]
	var stats = actor_data["stats"]
	max_hp = int(stats["max_hp"]); max_resist = int(stats["max_resist"])
	hp = max_hp; resist = max_resist
	speed = {
		"min": int(stats["speed"]['min']),
		"max": int(stats["speed"]['max']),
	}
	resistences = actor_data['resistences']
	init_sprites(actor_data)
	init_speed_dices(int(stats["speed_dices"]))
	max_light = stats['light']
	init_light(stats['light'])
	init_gauges()
	status_effects = stats['status_effects']
	init_status_effects()
	dependencies = actor_dependencies
	print(
		'Inited Actor: ' + actor_data["name"] 
		+ '; ID: ' + str(int(actor_data["id"])) 
		+ '; Code: ' + actor_data['code']
	)

func get_actor_height():
	return $Sprite.sprite_frames.get_frame_texture(
		$Sprite.animation,
		$Sprite.frame
	).get_height()

func init_sprites(actor_data):
	$Sprite.sprite_frames = SpriteFrames.new()
	load_animation('default', actor_data['code'])

func load_animation(animation_name, actor_code):
	var texture = load('res://media/actors/sprites/' + actor_code + '/' + animation_name + '.png')
	if not $Sprite.sprite_frames.has_animation(animation_name):
		$Sprite.sprite_frames.add_animation(animation_name)
	$Sprite.sprite_frames.add_frame(animation_name, texture)

func init_speed_dices(count):
	var dice_scene = preload('res://act/dices/speed_dice.tscn')
	for i in count:
		var dice: TextureButton = dice_scene.instantiate()
		dice.scale = Vector2(0.85, 0.85)
		var actor_height = get_actor_height()
		$SpeedDices.add_child(dice)
		dice.position.y -= actor_height / 2
		dice.position.y -= dice.get_rect().size.y
		dice.position.x -= (dice.get_rect().size.x * count) / 2
		dice.position.x += i * dice.get_rect().size.x
		dice.init(speed)

func init_light(count):
	for i in count:
		var light: TextureRect = TextureRect.new()
		light.texture = preload('res://media/actors/light.png')
		light.scale = Vector2(0.60, 0.60)
		$Lights.add_child(light)
		var gap = 10
		light.position.y -= get_actor_height() / 2
		light.position.y -= $SpeedDices.get_child(0).get_rect().size.y
		light.position.y -= light.get_rect().size.y + 10
		var total_width = (light.get_rect().size.x * count) + (gap * (count - 1))
		light.position.x -= total_width / 2
		light.position.x += (light.get_rect().size.x + gap) * i

func init_gauges():
	$Gauges/Health.max_value = max_hp
	$Gauges/Health.value = max_hp
	$Gauges/Health/HP.text = str(max_hp)
	$Gauges/Resist.max_value = max_resist
	$Gauges/Resist.value = max_resist
	$Gauges/Resist/RP.text = str(max_resist)

func init_status_effects():
	var i = 0
	for effect_data in status_effects:
		var effect: TextureRect = preload("res://act/actors/status_effect.tscn").instantiate()
		effect.texture = load("res://media/actors/status_effects/" + effect_data['code'] + ".png")
		effect.get_node("Stacks").text = str(int(effect_data["stacks"]))
		$StatusEffects.add_child(effect)
		effect.scale = Vector2(0.50, 0.50)
		effect.position.y += 113
		var total_width = effect.get_rect().size.x * status_effects.size()
		effect.position.x -= total_width / 2
		effect.position.x += effect.get_rect().size.x * i
		i += 1

func focus_self():
	$Glow.show()
	$Gauges/Health.z_index = 1
	$Gauges/Resist.z_index = 1

func unfocus_self():
	$Glow.hide()
	$Gauges/Health.z_index = 0
	$Gauges/Resist.z_index = 0

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		dependencies['actor_details'].select_actor(id)

func roll_speed_dice():
	for dice in $SpeedDices.get_children():
		var n = randi_range(speed['min'], speed['max'])
		dice.set_speed(n)
