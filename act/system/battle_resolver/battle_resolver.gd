class_name BattleResolver extends RefCounted

const BattleSFX = preload('res://act/music/sfx/battle.gd')
const Camera = preload("res://act/scenary/camera/camera.gd")
const Actors = preload("res://act/scenary/actors/actors.gd")
const CardResolver = preload("res://act/scenary/actors/card_resolver/card_resolver.gd")
const ClashResolver = preload('res://act/system/battle_resolver/clash_resolver.gd')

signal roll_dices_confirmed

## Battle Resolver States
enum States { AUTOPLAY, AWAITING_CONFIRMATION }

## Battle Resolver current status
var status: States = States.AUTOPLAY

# Act Reference
var act: Act

## Camera reference
var camera: Camera

## Event Queue reference
var event_queue: EventQueue

## Actors reference
var actors: Actors

## Original actors' z_index backup
var actors_z_index: Dictionary[String, int] = { 'a': 0, 'b': 0}

## Turn Manager Reference
var turn_manager: TurnManager

## Dice Roll SFX reference
var dice_roll_sfx: AudioStreamPlayer

## Battle SFX reference
var battle_sfx: BattleSFX

var clash_resolver: ClashResolver

func init() -> void:
	clash_resolver = ClashResolver.new(
		act, camera, battle_sfx
	)

# --- --- Dice Roller Event Handlers
func handle_dice_roller_pressed() -> void:
	roll_dices()

# --- --- Space Event Handlers
func handle_space_pressed() -> void:
	roll_dices()

## Roll Dices
func roll_dices() -> void:
	if status == States.AWAITING_CONFIRMATION:
		roll_dices_confirmed.emit()
		dice_roll_sfx.play()

## Resolve Event Queue
func resolve_events() -> void:
	# Hide Actors Dices and Light
	actors.hide_everyone_ui_components()
	# Order Event Queue
	event_queue.order_by_speed()
	# Log Events for Debug
	#event_queue.log_in_console()
	# Check for if any event
	if event_queue.size() > 0:
		actors.rush_everyone_to_targets()
		for event: Event in event_queue.events:
			var actors_alive: bool = check_actors_alive(event.get_actors())
			actors.hide_dead_actors()
			if actors_alive:
				await resolve_event(event)
			else:
				continue
	event_queue.clear_all_references()
	event_queue.remove_all()
	actors.clear_everyone_card_resolver()
	actors.remove_dead_actors()
	actors.clear_everyone_defensive_dice_queue()
	act.handle_scene_finished()

## Check Actor Alive
func check_actors_alive(p_actors: Array[Actor]) -> bool:
	return p_actors[0].alive and p_actors[1].alive

## Resolve Battle Event
func resolve_event(event: Event) -> void:
	var speed_dices: Array[SpeedDice] = event.get_speed_dices()
	var speed_dice_a: SpeedDice = speed_dices[0]
	var speed_dice_b: SpeedDice = speed_dices[1]
	var actor_a: Actor = speed_dice_a.parent_actor
	var actor_b: Actor = speed_dice_b.parent_actor
	# Zoom into current Event
	camera.zoom_into_battle_event(event)
	actors_z_index['a'] = actor_a.z_index
	actors_z_index['b'] = actor_b.z_index
	actor_a.z_index = 1000
	actor_b.z_index = 1000
	# Checks if Actor's Speed Dice is Targeting the enemy Actor in this Event
	var a_is_rushing: bool = check_if_is_targeting_enemy(speed_dice_a, actor_b, event)
	var b_is_rushing: bool = check_if_is_targeting_enemy(speed_dice_b, actor_a, event)
	# Await if any actor is rushing
	if a_is_rushing: await actor_a.enemy_reached
	elif b_is_rushing: await actor_b.enemy_reached
	# Get Card Resolvers
	var card_resolver_a: CardResolver = actor_a.get_card_resolver()
	var card_resolver_b: CardResolver = actor_b.get_card_resolver()
	# Checks Dice Queues
	while(
		card_resolver_a.has_dice()
		or card_resolver_b.has_dice()
	):
		## Check if actors are still alive
		var actors_alive: bool = check_actors_alive(event.get_actors())
		if not actors_alive: break
		# A and B has dices
		if(
			card_resolver_a.has_dice()
			and card_resolver_b.has_dice()
		):
			actor_a.rush_to_enemy(actor_b)
			actor_b.rush_to_enemy(actor_a)
			camera.zoom_into_battle_event(event)
			await camera.zooming_finished
			await handle_clash_approach(actor_a, actor_b)
		# Only A has dice
		elif card_resolver_a.has_dice():
			await handle_oneside_approach(event, actor_a, actor_b)
		# Only B has dice
		elif card_resolver_b.has_dice():
			await handle_oneside_approach(event, actor_b, actor_a)
	actor_a.z_index = actors_z_index['a']
	actor_a.idle()
	actor_a.clear_card_resolver()
	actor_b.z_index = actors_z_index['b']
	actor_b.idle()
	actor_b.clear_card_resolver()

## Both has Dice
func handle_clash_approach(
	actor_a: Actor,
	actor_b: Actor
) -> void:
	# Get Card Resolvers
	var card_resolver_a: CardResolver = actor_a.get_card_resolver()
	var card_resolver_b: CardResolver = actor_b.get_card_resolver()
	if(
		not is_controlled_by_ai(actor_a)
		and is_controlled_by_ai(actor_b)
	):
		await set_timeout()
		card_resolver_b.play_dice()
		await player_confirmation()
		card_resolver_a.play_dice()
	elif(
		not is_controlled_by_ai(actor_b)
		and is_controlled_by_ai(actor_a)
	):
		await set_timeout()
		card_resolver_a.play_dice()
		await player_confirmation()
		card_resolver_b.play_dice()
	else:
		if is_controlled_by_ai(actor_a):
			await set_timeout()
			dice_roll_sfx.play()
		else:
			await player_confirmation()
		card_resolver_a.play_dice()
		if is_controlled_by_ai(actor_b):
			await set_timeout()
			dice_roll_sfx.play()
		else:
			await player_confirmation()
		card_resolver_b.play_dice()
	await resolve_clash(
		card_resolver_a,
		card_resolver_b,
	)

## Only one has Dice
func handle_oneside_approach(
	event: Event,
	attacker: Actor,
	target: Actor
) -> void:
	var card_resolver: CardResolver = attacker.get_card_resolver()
	attacker.rush_to_enemy(target)
	target.face_enemy(attacker)
	camera.zoom_into_battle_event(event)
	await camera.zooming_finished
	if target.defensive_dice_queue.is_empty():
		if card_resolver.get_current_dice_resource().is_offensive():
			# Dice is offensive
			# Play dice
			if not is_controlled_by_ai(attacker):
				await player_confirmation()
			else:
				await set_timeout()
			await resolve_oneside(
				card_resolver, target
			)
		elif(
			card_resolver.get_current_dice_resource().is_defensive()
			and not attacker.using_defensive_dice_queue
		):
			# Dice is defensive
			# Save dice in the defensive dice queue
			var dices: Array[DiceResource]
			dices.append(card_resolver.get_current_dice_resource())
			card_resolver.fade_out_current_dice()
			dices.append_array(card_resolver.pull_defensive_dices())
			attacker.defensive_dice_queue.append_array(dices)
			await set_timeout(0.5)
			card_resolver.discard_current_dice()
		else:
			attacker.store_defensive_dice_queue()
			await set_timeout(0.5)
			card_resolver.discard_current_dice()
	else:
		target.use_defensive_dice_queue()
		await handle_clash_approach(attacker, target)

## Resolve Clash
func resolve_clash(
	card_resolver_a: CardResolver,
	card_resolver_b: CardResolver
) -> void:
	await clash_resolver.resolve(card_resolver_a, card_resolver_b)

## Resolve Oneside
func resolve_oneside(card_resolver: CardResolver, enemy: Actor) -> void:
	card_resolver.play_dice()
	var value: int = card_resolver.get_dice_value()
	var actor: Actor = card_resolver.parent_actor
	var dice_type: String = card_resolver.get_dice_type_string() # SLASH, PIERCE, BLUNT, BLOCK, EVADE
	var attack_animation: String = actor.play_attack_animation()
	camera.shake()
	battle_sfx.play_attack(actor.sharp_weapon, attack_animation)
	await enemy.handle_hit(
		value, dice_type, actor.global_position, attack_animation
	)
	card_resolver.discard_current_dice()

## Await Player Confirmation
func player_confirmation() -> void:
	status = States.AWAITING_CONFIRMATION
	await roll_dices_confirmed
	status = States.AUTOPLAY

## Checks if Speed Dice is Targeting an enemy Actor
func check_if_is_targeting_enemy(
	speed_dice: SpeedDice,
	target: Actor,
	event: Event
) -> bool:
	# Check Speed Dice target
	if speed_dice.is_targeting_enemy(target):
		# Get Actor
		var actor: Actor = speed_dice.parent_actor
		# Actor rush to its target
		actor.rush_to_enemy(target)
		# Load SpeedDice Card in CardResolver if any
		load_speed_dice_card(actor, speed_dice, event)
		return true
	return false

## Load SpeedDice's Card in CardResolver if any
func load_speed_dice_card(
	actor: Actor,
	speed_dice: SpeedDice,
	event: Event
) -> void:
	# Get Card
	var card_resource: CardResource = event\
		.get_card_of_speed_dice(speed_dice)
	# Resolve Card if Any
	if card_resource:
		# Use Card
		actor.use_card(card_resource)

## Is Actor Controlled by AI?
func is_controlled_by_ai(actor: Actor) -> bool:
	return turn_manager.is_actor_controlled_by_ai(actor)

## Await timeout
func set_timeout(time: float = 0.3):
	await act.get_tree().create_timer(time).timeout
