class_name Actor extends Area2D

const SpeedDiceScene: PackedScene = preload('res://act/actors/dices/speed_dice/speed_dice.tscn')
const ActorControl = preload('res://act/hud/actors/actor_control/actor_control.gd')

signal actor_mouse_entered(actor: Actor)

signal actor_mouse_exited(actor: Actor)

signal actor_pressed(actor: Actor)

## 'left' | 'right'
var team: String

## Unique ID
var id: int

## Actor Name lower and sneak case.
## For example: Leiana Azure => leiana_azure
var code: String

## Actor Name for UI
var actor_name: String

## Max HP
var max_hp: int

## Max Resist
var max_resist: int

## Current HP
var hp: int

## Current Resist
var resist: int

## Actor Speed for each Speed Dice.
## For example: { "min": 2, "max": 4 }
var speed: Dictionary[String, int]

## Max Light
var max_light: int

## [PROVISIONAL] Actor Status Effects.
## Temporally: [ { "id": 1, "name": "Paralysis", "code": "paralysis", "stacks": 4 }, ... ]
var status_effects: Array

## [PROVISIONAL] Actor Resistences.
## Temporally: { "slash_damage": "normal", "slash_resist": "normal", "pierce_damage": "normal", "pierce_resist": "normal", "blunt_damage": "normal", "blunt_resist": "normal" }
var resistences: Dictionary

var deck: Array[CardResource] = []

var hand: Array[CardResource] = []

var dependencies: Dictionary = {}

# Reference to UI control title
var actor_control: ActorControl

func _ready():
	$CollisionShape.shape = $CollisionShape.shape.duplicate()

func init(actor_data: Dictionary, actor_dependencies) -> void:
	dependencies = actor_dependencies
	team = actor_data['team']
	id = int(actor_data['id'])
	code = actor_data['code']
	actor_name = actor_data["name"]
	var stats: Dictionary = actor_data["stats"]
	max_hp = int(stats["max_hp"]); max_resist = int(stats["max_resist"])
	hp = max_hp; resist = max_resist
	speed = {
		"min": int(stats["speed"]['min']),
		"max": int(stats["speed"]['max']),
	}
	resistences = actor_data['resistences']
	init_deck(actor_data['deck'])
	init_sprites()
	init_speed_dices(int(stats["speed_dices"]))
	max_light = stats['light']
	init_light(int(stats['light']))
	init_gauges()
	status_effects = stats['status_effects']
	init_status_effects()
	transform = transform.scaled(Vector2(0.55, 0.55))
	print(
		'Inited Actor: ' + actor_data["name"] 
		+ '; ID: ' + str(int(actor_data["id"])) 
		+ '; Code: ' + actor_data['code']
	)

func init_deck(deck_data: Array) -> void:
	var i: int = 1
	for card_code: String in deck_data:
		var card: CardResource = load('res://database/cards/' + card_code + '.tres')
		card.id = i + (id * 100)
		deck.append(card)
		i += 1
	for j: int in 3:
		var random_card: CardResource = deck.pick_random()
		hand.append(random_card)
		deck.erase(random_card)

func init_sprites() -> void:
	$Sprite.sprite_frames = SpriteFrames.new()
	load_animation('default')
	# Here you can load more animations

func load_animation(animation_name: String) ->void:
	var texture: Resource = load('res://media/actors/sprites/' + code + '/' + animation_name + '.png')
	if not $Sprite.sprite_frames.has_animation(animation_name):
		$Sprite.sprite_frames.add_animation(animation_name)
	$Sprite.sprite_frames.add_frame(animation_name, texture)

func init_speed_dices(count: int) -> void:
	for i: int in count:
		var speed_dice: SpeedDice = SpeedDiceScene.instantiate() as SpeedDice
		$SpeedDices.add_child(speed_dice)
		speed_dice.scale = Vector2(0.85, 0.85)
		speed_dice.self_positionate(i, get_actor_height(), count)
		speed_dice.parent_actor = self
		speed_dice.init(speed, (id * 1000) + i, dependencies)

func init_light(count: int):
	for i: int in count:
		var light: TextureRect = TextureRect.new()
		light.texture = preload('res://media/actors/light.png')
		light.scale = Vector2(0.60, 0.60)
		$Lights.add_child(light)
		var gap: float = 10.00
		light.position.y -= get_actor_height() / 2
		light.position.y -= $SpeedDices.get_child(0).get_rect().size.y
		light.position.y -= light.get_rect().size.y + 10
		var total_width: float = (light.get_rect().size.x * count) + (gap * (count - 1))
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
	var i: int = 0
	for effect_data in status_effects:
		var effect: TextureRect = preload("res://act/actors/status_effect.tscn").instantiate()
		effect.texture = load("res://media/actors/status_effects/" + effect_data['code'] + ".png")
		effect.get_node("Stacks").text = str(int(effect_data["stacks"]))
		$StatusEffects.add_child(effect)
		effect.scale = Vector2(0.50, 0.50)
		effect.position.y += 113
		var total_width: float = effect.get_rect().size.x * status_effects.size()
		effect.position.x -= total_width / 2
		effect.position.x += effect.get_rect().size.x * i
		i += 1

func flip_h_sprite(value: bool):
	$Sprite.flip_h = value

## Get Actor's current frame height in pixels
func get_actor_height() -> float:
	return $Sprite.sprite_frames.get_frame_texture(
		$Sprite.animation,
		$Sprite.frame
	).get_height() as float

## Focus Actor
func focus_self():
	$Glow.show()
	$Gauges/Health.z_index = 1
	$Gauges/Resist.z_index = 1

## Unfocus Actor
func unfocus_self():
	$Glow.hide()
	$Gauges/Health.z_index = 0
	$Gauges/Resist.z_index = 0

func roll_speed_dice():
	for dice: SpeedDice in $SpeedDices.get_children():
		var n: int = randi_range(speed['min'], speed['max'])
		dice.set_speed(n)
		dice.dice_mouse_entered.connect(_on_dice_mouse_entered)
		dice.dice_mouse_exited.connect(_on_dice_mouse_exited)
		dice.dice_pressed.connect(_on_dice_pressed)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		actor_pressed.emit(self)

func _on_mouse_entered() -> void:
	actor_mouse_entered.emit(self)

func _on_mouse_exited() -> void:
	actor_mouse_exited.emit(self)

func _on_dice_mouse_entered(_dice):
	pass
	#dependencies['actor_details'].hover_tracer = 'control'
	#dependencies['actor_details'].actor_hovered = self
	#dependencies['actor_details'].show_details(id)
	#dependencies['actor_details'].actor_control_hovered = actor_control
	#dependencies['hand'].handle_dice_mouse_entered(self, dice)
	#dependencies['arrows'].handle_dice_mouse_entered(dice)

func _on_dice_mouse_exited(_dice):
	pass
	#dependencies['actor_details'].hover_tracer = 'area2d'
	#dependencies['actor_details'].actor_hovered = null
	#dependencies['actor_details'].hide_details(id)
	#dependencies['actor_details'].actor_control_hovered = null
	#dependencies['hand'].handle_dice_mouse_exited(self, dice)
	#dependencies['arrows'].handle_dice_mouse_exited(dice)

func _on_dice_pressed(_dice):
	pass
	#dependencies['actor_details'].select_actor(id)
	#dependencies['hand'].handle_dice_pressed(self, dice)
