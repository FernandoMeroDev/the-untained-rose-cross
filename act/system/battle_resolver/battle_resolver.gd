class_name BattleResolver extends RefCounted

const Camera = preload("res://act/scenary/camera/camera.gd")
const Actors = preload("res://act/scenary/actors/actors.gd")
const CardResolver = preload("res://act/scenary/actors/card_resolver/card_resolver.gd")

signal attack_resolved

signal roll_dices_confirmed

## Battle Resolver States
enum States { AUTOPLAY, AWAITING_CONFIRMATION }

## Battle Resolver current status
var status: States = States.AUTOPLAY

## Camera reference
var camera: Camera

## Event Queue reference
var event_queue: EventQueue

## Actors reference
var actors: Actors

## Turn Manager Reference
var turn_manager: TurnManager

## Dice Roll SFX reference
var dice_roll_sfx: AudioStreamPlayer

# --- --- Space Event Handlers
func handle_space_pressed() -> void:
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
			await resolve_event(event)

## Resolve Battle Event
func resolve_event(event: Event) -> void:
	var speed_dices: Array[SpeedDice] = event.get_speed_dices()
	var speed_dice_a: SpeedDice = speed_dices[0]
	var speed_dice_b: SpeedDice = speed_dices[1]
	var actor_a: Actor = speed_dice_a.parent_actor
	var actor_b: Actor = speed_dice_b.parent_actor
	# Zoom into current Event
	camera.zoom_into_battle_event(event)
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
		card_resolver_a.queue_is_not_empty()
		or card_resolver_b.queue_is_not_empty()
	):
		# A and B has dices
		if(
			card_resolver_a.has_dice()
			and card_resolver_b.has_dice()
		):
			if(
				not is_controlled_by_ai(actor_a)
				and is_controlled_by_ai(actor_b)
			):
				card_resolver_b.play_dice()
				await player_confirmation()
				card_resolver_a.play_dice()
				await card_resolver_a.dice_value_setted
			elif(
				not is_controlled_by_ai(actor_b)
				and is_controlled_by_ai(actor_a)
			):
				card_resolver_a.play_dice()
				await player_confirmation()
				card_resolver_b.play_dice()
				await card_resolver_b.dice_value_setted
			else:
				if not is_controlled_by_ai(actor_a):
					await player_confirmation()
				card_resolver_a.play_dice()
				if not is_controlled_by_ai(actor_b):
					await player_confirmation()
				card_resolver_b.play_dice()
				await card_resolver_b.dice_value_setted
			resolve_clash(
				card_resolver_a,
				card_resolver_b,
			)
		# Only A has dice
		elif card_resolver_a.has_dice():
			if not is_controlled_by_ai(actor_a):
				await player_confirmation()
			card_resolver_a.play_dice()
			await card_resolver_a.dice_value_setted
			resolve_oneside()
		# Only B has dice
		elif card_resolver_b.has_dice():
			if not is_controlled_by_ai(actor_b):
				await player_confirmation()
			card_resolver_b.play_dice()
			await card_resolver_b.dice_value_setted
			resolve_oneside()
		await attack_resolved
	# Await Event for resolve
	await event.event_resolved
	print('Event Resolved')

## Resolve Clash
func resolve_clash(
	card_resolver_a: CardResolver,
	card_resolver_b: CardResolver
) -> void:
	print('Resolve Clash')
	if(
		card_resolver_a.get_dice_value() 
		> card_resolver_b.get_dice_value()
	):
		print('A wins B')
	elif(
		card_resolver_a.get_dice_value() 
		< card_resolver_b.get_dice_value()
	):
		print('B wins A')
	else:
		print('Equals')

## Resolve Oneside
func resolve_oneside() -> void:
	print('Resolve Oneside')

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
