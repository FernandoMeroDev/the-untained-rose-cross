class_name Actor extends Area2D

const SpeedDiceScene: PackedScene = preload('res://act/scenary/actors/dices/speed_dice/speed_dice.tscn')
const ActorControl = preload('res://act/hud/actors/actor_control/actor_control.gd')
const CardResolver = preload("res://act/scenary/actors/card_resolver/card_resolver.gd")
const EmotionPoint = preload("res://act/hud/actors/actor_control/emotion_points/point.gd")

signal actor_mouse_entered(actor: Actor)

signal actor_mouse_exited(actor: Actor)

signal actor_pressed(actor: Actor)

signal actor_emotionalized()

signal actor_died(actor: Actor)

## Emitted when an enemy actor is physically reached
signal enemy_reached(actor: Actor, enemy: Actor)

## Actor States
enum States { IDLE, RUSHING }

## Actor current status
var status: States = States.IDLE

## Actor Attack Types
enum AttackTypes { HORI, VERT, STAB }

## Act reference
var act: Act

## Turn Manager reference
var turn_manager: TurnManager

## Actor Team
var team: TurnManager.Teams

## Position Marker2D reference
var position_marker2d: Marker2D

## Unique ID
var id: int

## Actor Name lower and sneak case.
## For example: Leiana Azure => leiana_azure
var code: String

## Actor Name for UI
var actor_name: String

## Actor Weapon Sharpness
var sharp_weapon: bool

## Max HP
var max_hp: int

## Max Resist
var max_resist: int

## Current HP
var hp: int

## Current Resist
var resist: int

## Max Emotion Level
var max_emotion_level: int

## Current Emotion Level
var emotion_level: int = 0

## Current Emotion Points
var emotion_points: int = 0

## Is Actor Alive?
var alive: bool = true

## Is Actor Staggered?
var staggered: bool = false

## Staggered Scenes Remain for recover
var staggered_remain: int = 0

## Actor Speed for each Speed Dice.
## For example: { "min": 2, "max": 4 }
var speed: Dictionary[String, int]

## Actor Status Effects [TODO: transform into Resource]
## Temporally: [ { "id": 1, "name": "Paralysis", "code": "paralysis", "stacks": 4 }, ... ]
var status_effects: Array

## Actor current Resistences. [TODO: Improve this]
## Temporally: { "slash_damage": "normal", "slash_resist": "normal", "pierce_damage": "normal", "pierce_resist": "normal", "blunt_damage": "normal", "blunt_resist": "normal" }
var resistences: Dictionary

## Actor original Resistences. [TODO: Improve this]
## Temporally: { "slash_damage": "normal", "slash_resist": "normal", "pierce_damage": "normal", "pierce_resist": "normal", "blunt_damage": "normal", "blunt_resist": "normal" }
var original_resistences: Dictionary

## Actor Deck
var deck: Array[CardResource] = []

## Actor Hand
var hand: Array[CardResource] = []

## Target when Actor is rushing (RUSHING status)
var target_actor: Actor

## Reference to UI control title
var actor_control: ActorControl

## Defensive Dice Queue
var defensive_dice_queue: Array[DiceResource] = []

## Is using Defensive Dice Queue
var using_defensive_dice_queue: bool = false

## Is Actor horizontally flipped?
var actor_flip_h: bool = false

## Count of Cards used in the last scene
var cards_used_count: int = 0

func _on_mouse_entered() -> void:
	actor_mouse_entered.emit(self)

func _on_mouse_exited() -> void:
	actor_mouse_exited.emit(self)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# Handle pressed Left Click
	if event.is_action_pressed("left_click"):
		actor_pressed.emit(self)

# --- Battle Resolver Event Handlers
## Handle Damaged logic, display animation and effects
func handle_hit(
	value: int, 
	damage_type: String,
	attack_type: String,
	enemy: Actor
) -> void:
	# Take Damage logic
	take_damage(
		value, 
		damage_type, 
		enemy.get_card_resolver().get_current_dice_max_value()
	)
	# Knockback
	knockback(
		(global_position - enemy.global_position).normalized()
	)
	# Show VFX
	$VFX/HitTrail.hit(attack_type)
	$VFX/BloodSplash.splash()
	# Damage results
	if hp <= 0:
		hp = 0
		# Actor Die
		$Sprite.play('defeated')
		die()
		# Enemy Refill 1 Light
		enemy.refill_light(1)
		# Enemy Emotionalize
		enemy.emotionalize(3, EmotionPoint.Types.POSITIVE)
	else:
		# Change Sprite
		$Sprite.play('damaged')
	if resist <= 0:
		resist = 0
		# Set Staggered Status
		if not staggered:
			stagger()
			# Enemy Refill 1 Light
			enemy.refill_light(1)
	await set_timeout(0.5)

## Handle Parry
func handle_parry() -> void:
	play_attack_animation(false)

## Handle deflected
func handle_deflected(value: int, enemy: Actor) -> void:
	resist -= value
	$Gauges.take_stagger_damage(value)
	# Change Sprite
	$Sprite.play('damaged')
	# Knockback
	knockback(
		(global_position - enemy.global_position).normalized()
	)
	# Damage Tags
	$DamageTags.show_deflect_damage(value)
	# Handle resist substraction
	if resist <= 0:
		resist = 0
		# Set Staggered Status
		if not staggered:
			stagger()
			# Enemy Refill 1 Light
			enemy.refill_light(1)

func _ready() -> void:
	$CollisionShape.shape = $CollisionShape.shape.duplicate()
	$Sprite.material = $Sprite.material.duplicate()

func _process(delta: float) -> void:
	if status == States.RUSHING:
		var direction: Vector2 = (
			target_actor.global_position - global_position
		).normalized()
		# Flip according the movement direction
		if direction.x >= 0.0:
			if actor_flip_h:
				flip_h(false)
		else:
			if not actor_flip_h:
				flip_h(true)
		var x_position = Vector2(global_position.x, 0)
		var y_position = Vector2(0, global_position.y)
		var target_x_position = Vector2(target_actor.global_position.x, 0)
		var target_y_position = Vector2(0, target_actor.global_position.y)
		if(
			x_position.distance_to(target_x_position)
			< 100
		):
			direction.x = 0
		global_position += direction * 800 * delta
		if(
			x_position.distance_to(target_x_position) < 100
			and y_position.distance_to(target_y_position) < 10
		):
		#if(
			#global_position.distance_to(target_actor.global_position) 
			#< 100
		#):
			enemy_reached.emit(self, target_actor)
			status = States.IDLE

func init(actor_data: Dictionary) -> void:
	team = (
		turn_manager.Teams.LEFT if (
			actor_data['team'] == 'left'
		) else turn_manager.Teams.RIGHT
	)
	id = int(actor_data['id'])
	code = actor_data['code']
	actor_name = actor_data["name"]
	sharp_weapon = actor_data["sharp_weapon"]
	var stats: Dictionary = actor_data["stats"]
	max_hp = int(stats["max_hp"]); max_resist = int(stats["max_resist"])
	hp = max_hp; resist = max_resist
	speed = {
		"min": int(stats["speed"]['min']),
		"max": int(stats["speed"]['max']),
	}
	resistences = actor_data['resistences']
	original_resistences = resistences.duplicate_deep()
	init_deck(actor_data['deck'])
	init_sprites()
	init_speed_dices(int(stats["speed_dices"]))
	init_light(int(stats['light']))
	init_gauges()
	status_effects = stats['status_effects']
	init_status_effects()
	transform = transform.scaled(Vector2(0.55, 0.55))
	init_card_resolver()
	init_vfx()
	$DamageTags.resistences_values = resistences
	#print(
		#'Inited Actor: ' + actor_data["name"] 
		#+ '; ID: ' + str(int(actor_data["id"])) 
		#+ '; Code: ' + actor_data['code']
	#)

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
	load_animation('rushing')
	load_animation('vert')
	load_animation('stab')
	load_animation('hori')
	load_animation('block')
	load_animation('evade')
	load_animation('damaged')
	load_animation('defeated')
	# Here you can load more animations

func load_animation(animation_name: String) ->void:
	var texture: Resource = load('res://media/actors/sprites/' + code + '/' + animation_name + '.png')
	if not $Sprite.sprite_frames.has_animation(animation_name):
		$Sprite.sprite_frames.add_animation(animation_name)
	$Sprite.sprite_frames.add_frame(animation_name, texture)

func init_speed_dices(count: int, p_hidden: bool = false) -> void:
	for i: int in count:
		var speed_dice: SpeedDice = SpeedDiceScene.instantiate() as SpeedDice
		$SpeedDices.add_child(speed_dice)
		speed_dice.scale = Vector2(0.85, 0.85)
		speed_dice.self_positionate(i, get_actor_height(), count)
		speed_dice.parent_actor = self
		speed_dice.init(speed, (id * 1000) + (i + 1))
		if p_hidden: speed_dice.hide()

func init_light(count: int):
	$Lights.parent_actor = self
	$Lights.max_light = count
	$Lights.refill_max_value()

func init_gauges() -> void:
	$Gauges/Health.max_value = max_hp
	$Gauges/Health.value = max_hp
	$Gauges/Health/HP.text = str(max_hp)
	$Gauges/Resist.max_value = max_resist
	$Gauges/Resist.value = max_resist
	$Gauges/Resist/RP.text = str(max_resist)

func init_status_effects() -> void:
	var i: int = 0
	for effect_data in status_effects:
		var effect: TextureRect = preload("res://act/scenary/actors/status_effect.tscn").instantiate()
		effect.texture = load("res://media/actors/status_effects/" + effect_data['code'] + ".png")
		effect.get_node("Stacks").text = str(int(effect_data["stacks"]))
		$StatusEffects.add_child(effect)
		effect.scale = Vector2(0.50, 0.50)
		effect.position.y += 113
		var total_width: float = effect.get_rect().size.x * status_effects.size()
		effect.position.x -= total_width / 2
		effect.position.x += effect.get_rect().size.x * i
		i += 1

func init_card_resolver() -> void:
	$CardResolver.parent_actor = self

func init_vfx() -> void:
	$VFX.parent_actor = self
	$VFX.init()

## Checks for light for use a card.
## Extra light is when the actor is already holding a card
func can_use_card(card: CardResource, extra_light: int = 0) -> bool:
	return $Lights.value + extra_light >= card.cost

## Refound card to hand
func refound_card_to_hand(card: CardResource) -> void:
	hand.append(card)
	$Lights.add_lights(card.cost)

## Refill Light
func refill_light(count: int = 1) -> void:
	if not staggered:
		$Lights.add_lights(count)

## Actor count cards used
func count_cards_used() -> void:
	for speed_dice: SpeedDice in $SpeedDices.get_children():
		if speed_dice.battle_event:
			cards_used_count += 1

## Draw Cards from Deck
func draw_cards(count: int = 1) -> void:
	if emotion_level == 5 and cards_used_count >= 2:
		count = 2
	for i in count:
		if not deck.is_empty():
			hand.append(
				deck.pop_at(randi_range(0, deck.size() - 1))
			)

## Use card from hand
func use_card_from_hand(card: CardResource) -> void:
	hand.erase(card)
	$Lights.sub_lights(card.cost)

## Pick random usable card. This doesnt erase the card from hand
func pick_random_usable_card() -> CardResource:
	var usable_cards: Array[CardResource]
	for card: CardResource in hand:
		if can_use_card(card):
			usable_cards.append(card)
	if usable_cards.size() > 0:
		return usable_cards.pick_random()
	else:
		return null

## Flip Horizontally Sprite and Card
func flip_h(flip: bool) -> void:
	$Sprite.flip_h = flip
	$CardResolver.flip_h_card(flip)
	$VFX.flip_h_vfx(flip)
	$DamageTags.flip_h_tags(flip)
	$RecoverTags.flip_h_tags(flip)
	actor_flip_h = flip

## Face enemy flipping horizontally
func face_enemy(enemy: Actor) -> void:
	flip_h(not enemy.actor_flip_h)

## Get Actor Reach Point
func get_reach_point() -> Vector2:
	return $ReachPoint.global_position

## Check if actor is in current turn
func is_my_turn() -> bool:
	return turn_manager.is_current_turn_of(self)

## Get Actor's current frame height in pixels
func get_actor_height() -> float:
	return $Sprite.sprite_frames.get_frame_texture(
		$Sprite.animation,
		$Sprite.frame
	).get_height() as float

## Get Actor Speed Dices
func get_speed_dices() -> Array[SpeedDice]:
	var speed_dices: Array[SpeedDice]
	for speed_dice: SpeedDice in $SpeedDices.get_children():
		speed_dices.append(speed_dice)
	return speed_dices

## Focus Actor
func focus_self() -> void:
	$Glow.show()
	$Gauges/Health.z_index = 1
	$Gauges/Resist.z_index = 1

## Unfocus Actor
func unfocus_self() -> void:
	$Glow.hide()
	$Gauges/Health.z_index = 0
	$Gauges/Resist.z_index = 0

## Roll Actor Speed Dices
func roll_speed_dices() -> void:
	for dice: SpeedDice in $SpeedDices.get_children():
		var speed_value: int = randi_range(speed['min'], speed['max'])
		if not staggered:
			dice.set_speed(speed_value)

## Restart Actor Speed Dices
func restart_speed_dices() -> void:
	for dice: SpeedDice in $SpeedDices.get_children():
		dice.reset()

## Hide Speed Dices
func hide_speed_dices() -> void:
	for dice: SpeedDice in $SpeedDices.get_children():
		dice.hide()

## Show Speed Dices
func show_speed_dices() -> void:
	for dice: SpeedDice in $SpeedDices.get_children():
		dice.show()

## Hide Lights
func hide_lights() -> void:
	$Lights.hide()

## Show Lights
func show_lights() -> void:
	$Lights.show()

## Rush to some target if any
func rush_to_target() -> void:
	var target_speed_dice: SpeedDice
	for speed_dice: SpeedDice in $SpeedDices.get_ordered_by_speed():
		if speed_dice.battle_event:
			target_speed_dice = speed_dice.battle_event\
				.get_target_of_speed_dice(speed_dice)
			rush_to_enemy(target_speed_dice.parent_actor)

## Rush to a given enemy (Actor)
func rush_to_enemy(enemy: Actor) -> void:
	target_actor = enemy
	$Sprite.play('rushing')
	status = States.RUSHING

## Loads Card in CardResolver
func use_card(card_resource: CardResource) -> void:
	if using_defensive_dice_queue:
		# Pulls defensive queue if actors was using it
		store_defensive_dice_queue()
	$CardResolver.load_card(card_resource)
	$CardResolver.show()
	$CardResolver.position = Vector2(0, 0)
	deck.append(card_resource)
	using_defensive_dice_queue = false

## Use Defensive dice queue for clash against enemy oneside attack
func use_defensive_dice_queue() -> void:
	$CardResolver.load_defensive_dice_queue(defensive_dice_queue)
	$CardResolver.show()
	$CardResolver.position = Vector2(0, 0)
	using_defensive_dice_queue = true

## Store defensive dice queue
func store_defensive_dice_queue() -> void:
	defensive_dice_queue = $CardResolver.get_all_dices()

## Returns to IDLE status
func idle() -> void:
	$CardResolver.hide()
	if staggered:
		$Sprite.play('damaged')
	else:
		$Sprite.play('default')
	status = States.IDLE

## Get Card Resolver
func get_card_resolver() -> CardResolver:
	return $CardResolver

## Attack. Display animation and effects. Returns attack animation:
## 'vert' | 'hori' | 'stab'
func play_attack_animation(draw_trail: bool = true) -> String:
	## 'vert' | 'hori' | 'stab'
	var attack_type: String = AttackTypes.keys().pick_random().to_lower()
	$Sprite.play(attack_type)
	if draw_trail: $VFX.show_attack_trail_of(attack_type)
	return attack_type

## Actor Knockback
func knockback(direction: Vector2) -> void:
	var distance: int = randi_range(80, 140)
	var final_position: Vector2 = global_position + (direction * distance)
	# Limits the movement area to Scenary's floor
	final_position.x = clamp(final_position.x, 100, get_viewport_rect().size.x - 100)
	final_position.y = clamp(final_position.y, 589.0, get_viewport_rect().size.y - 100)
	# Animation
	var tween = create_tween()
	tween.tween_property(
		self,
		"global_position",
		final_position,
		0.15
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

## Actor saddly Die
func die() -> void:
	alive = false
	actor_died.emit(self)

## Take Damage
func take_damage(
	value: int, 
	damage_type: String,
	max_possible_value: int
) -> void:
	# Calc damage in function of resistences
	var normal_damage: int = int(
		value * calc_resistence(damage_type + '_damage')
	)
	var stagger_damage: int = int(
		value * calc_resistence(damage_type + '_resist')
	)
	hp -= normal_damage
	resist -= stagger_damage
	$Gauges.take_damage(normal_damage, stagger_damage)
	actor_control.set_health_value(hp)
	# Blood
	$Sprite.material.set_shader_parameter(
		"blood_amount",
		calc_blood_amount()
	)
	# Max Damage
	if value == max_possible_value:
		$VFX.show_max_damage_vfx()
	# Damage Tags
	$DamageTags.show_damage('normal', normal_damage, damage_type)
	$DamageTags.show_damage('stagger', stagger_damage, damage_type)

## Set timeout
func set_timeout(time: float = 0.3) -> void:
	await get_tree().create_timer(time).timeout

## Calc Resistence value
func calc_resistence(resistence_name: String) -> float:
	var resistence_value: String = resistences[resistence_name]
	match resistence_value:
		"fatal": return 2.0
		"weak": return 1.5
		"normal": return 1.0
		"endured": return 0.5
		"ineffective": return 0.25
		_: return 0.0 # Immune

## Calc Blood amount for blood shader
func calc_blood_amount() -> float:
	var hp_percentaje: float = 1.0 - clamp(1.0 - (float(hp) / float(max_hp)), 0.0, 1.0)
	match hp_percentaje:
		# HP < 25% => 100% blood
		var p when p < 0.25: return 1.0
		# HP < 50% => 50% blood
		var p when p < 0.50: return 0.50
		# HP >= 50% => 0% blood
		_: return 0.0

## Play Parry Sparks particles
func play_parry_sparks(sparks_global_position: Vector2) -> void:
	$VFX/ParrySparks.global_position = sparks_global_position
	$VFX/ParrySparks.emitting = true

## Block. Display animation and effects
func play_block_animation(draw_vfx: bool = true) -> void:
	$Sprite.play('block')
	if draw_vfx:
		# Show Guarded Shock
		$VFX/GuardedShock.show_guarded_shock()

## Display Evade animation
func play_evade_animation(attacker_position: Vector2) -> void:
	var direction: Vector2 = (global_position - attacker_position).normalized()
	$Sprite.play('evade')
	# Dodge Movement
	var distance: int = randi_range(80, 140)
	var final_position: Vector2 = global_position + (direction * distance)
	# Limits the movement area to Scenary's floor
	final_position.x = clamp(final_position.x, 100, get_viewport_rect().size.x - 100)
	final_position.y = clamp(final_position.y, 589.0, get_viewport_rect().size.y - 100)
	# Animation
	var tween = create_tween()
	tween.tween_property(
		self,
		"global_position",
		final_position,
		0.15
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

## Recovers Stagger Resist
func recover_resist(value: int) -> void:
	resist += value
	$Gauges/Resist.recover(value)
	$RecoverTags.show_resist(value)

## Clear Card Resolver
func clear_card_resolver() -> void:
	$CardResolver.clear()

## Actor is Staggered
func stagger() -> void:
	staggered = true
	staggered_remain = 2
	resistences.clear()
	resistences.merge({ 
		"slash_damage": "fatal", "slash_resist": "fatal", 
		"pierce_damage": "fatal", "pierce_resist": "fatal", 
		"blunt_damage": "fatal", "blunt_resist": "fatal" 
	})
	$SpeedDices.destroy_dices()
	$CardResolver.clear()
	$VFX.show_staggered_vfx()

## Actor recover from Staggered
func recover_from_staggered() -> void:
	if staggered_remain > 0:
		staggered_remain -= 1
	if staggered_remain == 0 and staggered:
		staggered = false
		resistences.clear()
		resistences.merge(
			original_resistences.duplicate()
		)
		$Sprite.play('default')
		resist = int(max_resist)
		$Gauges/Resist.recover(resist)

## Play Idle Animation
func play_idle_animation() -> void:
	if staggered:
		$Sprite.play('damaged')
	else:
		$Sprite.play('default')

## Give Emotion
func emotionalize(points: int, type: EmotionPoint.Types) -> void:
	if not alive: return
	emotion_points += points
	match emotion_level:
		0:
			if emotion_points >= 3 and max_emotion_level > 0:
				increase_emotion_level(3, 3, type)
				$Lights.increase_max(1)
			else: actor_control.add_emotion_points(points, type)
		1:
			if emotion_points >= 3 and max_emotion_level > 1: 
				increase_emotion_level(3, 5, type)
				$Lights.increase_max(1)
			else: actor_control.add_emotion_points(points, type)
		2:
			if emotion_points >= 5 and max_emotion_level > 2:
				increase_emotion_level(5, 7, type)
				$Lights.increase_max(1)
			else: actor_control.add_emotion_points(points, type)
		3:
			if emotion_points >= 7 and max_emotion_level > 3:
				increase_emotion_level(7, 9, type)
				$Lights.increase_max(1)
				var speed_dices_count: int = $SpeedDices.get_children().size()
				$SpeedDices.remove_all()
				init_speed_dices(speed_dices_count + 1, true)
				act.init_actor_speed_dices(self)
			else: actor_control.add_emotion_points(points, type)
		4:
			if emotion_points >= 9 and max_emotion_level > 4:
				emotion_level += 1
				actor_emotionalized.emit()
				emotion_points = 9
				actor_control.set_emotion_level(emotion_level)
				actor_control.fill_emotion_points(type)
				$Lights.increase_max(1)
			else: actor_control.add_emotion_points(points, type)

## Increase emotion level
func increase_emotion_level(
	limit: int, next_limit: int, type: EmotionPoint.Types
) -> void:
	var spare_points: int = emotion_points - limit
	emotion_level += 1
	actor_control.set_emotion_level(emotion_level)
	emotion_points = 0
	actor_control.set_max_emotion_points(next_limit)
	if spare_points > 0:
		actor_control.add_emotion_points(spare_points, type)
	actor_emotionalized.emit()
