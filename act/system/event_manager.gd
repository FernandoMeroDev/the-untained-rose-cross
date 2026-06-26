class_name EventManager extends RefCounted

signal battle_event_removed(speed_dice: SpeedDice)

## Selected Sound
var selected: AudioStreamPlayer

## Event Queue
var event_queue: EventQueue = EventQueue.new()

# --- Speed Dice Events Listeners
func _on_speed_dice_right_click_pressed(speed_dice: SpeedDice) -> void:
	handle_speed_dice_right_click_pressed(speed_dice)

# --- Hand Events Listeners
func _on_enemy_speed_dice_targeted(
	speed_dice: SpeedDice,
	enemy_speed_dice: SpeedDice,
	card_resource: CardResource
) -> void:
	handle_enemy_speed_dice_targeted(
		speed_dice, enemy_speed_dice, card_resource
	)

# --- Speed Dice Events Handlers
func handle_speed_dice_right_click_pressed(speed_dice: SpeedDice) -> void:
	if speed_dice.parent_actor.is_my_turn():
		if speed_dice.battle_event:
			battle_event_removed.emit(speed_dice)
			remove_battle_event(speed_dice)

# --- Hand Events Handlers
func handle_enemy_speed_dice_targeted(
	speed_dice: SpeedDice,
	enemy_speed_dice: SpeedDice,
	card_resource: CardResource
) -> void:
	if speed_dice.battle_event:
		battle_event_removed.emit(speed_dice)
		remove_battle_event(speed_dice)
	var event: Event
	# Remove Card from hand
	speed_dice.parent_actor.hand.erase(card_resource)
	# Create Event
	#print('/* --- Create Event')
	#print(
		#speed_dice.parent_actor.actor_name
		#+ "'s dice "
		#+ str(speed_dice.id)
		#+ ' targeting '
		#+ enemy_speed_dice.parent_actor.actor_name
		#+ "'s dice "
		#+ str(enemy_speed_dice.id)
	#)
	event = create_battle_event(
		speed_dice,
		enemy_speed_dice,
		card_resource
	)
	event_queue.add(event)
	selected.play()

## Create Battle Event
func create_battle_event(
	speed_dice: SpeedDice,
	enemy_speed_dice: SpeedDice,
	card_resource: CardResource
) -> Event:
	var event: Event
	if enemy_speed_dice.battle_event:
		if is_targeting_back(speed_dice, enemy_speed_dice):
			event = create_clash_event(
				speed_dice, enemy_speed_dice, card_resource
			)
		else:
			if speed_dice.value > enemy_speed_dice.value:
				event = create_interception(
					speed_dice, enemy_speed_dice, card_resource
				)
			else:
				event = create_oneside_attack_event(
					speed_dice, enemy_speed_dice, card_resource
				)
	else:
		event = create_oneside_attack_event(
			speed_dice, enemy_speed_dice, card_resource
		)
	return event

## Create Oneside Attack Event
func create_oneside_attack_event(
	speed_dice: SpeedDice,
	enemy_speed_dice: SpeedDice,
	card_resource: CardResource
) -> OnesideAttack:
	var event: OnesideAttack = OnesideAttack.new(speed_dice, enemy_speed_dice, card_resource)
	event_queue.add(event)
	speed_dice.battle_event = event
	return event
	
## Create Clash Event
func create_clash_event(
	speed_dice: SpeedDice,
	enemy_speed_dice: SpeedDice,
	card_resource: CardResource
) -> Clash:
	var event: Clash = Clash.new(
		speed_dice,
		card_resource,
		enemy_speed_dice.battle_event.attacker_speed_dice,
		enemy_speed_dice.battle_event.attacker_card
	)
	speed_dice.battle_event = event
	enemy_speed_dice.battle_event = event
	return event

## Create Interception
func create_interception(
	speed_dice: SpeedDice,
	enemy_speed_dice: SpeedDice,
	card_resource: CardResource
) -> Event:
	var event: Event
	if is_instance_of(speed_dice.battle_event, Interception):
		# If dice was already being intercepted
		# just create a Oneside for now
		# Eventually it can implement target choose with TAB key
		event = create_oneside_attack_event(
			speed_dice, enemy_speed_dice, card_resource
		)
	else:
		# If it is Oneside or Clash
		# Backup enemy card before remove events
		var enemy_card: CardResource = enemy_speed_dice\
			.battle_event\
			.get_card_of_speed_dice(enemy_speed_dice)
		# Backup enemy dice intended before remove events
		var enemy_dice_intented: SpeedDice = enemy_speed_dice\
			.enemy_dice_intended as SpeedDice
		# Remove old enemy speed dice battle event
		remove_battle_event(enemy_speed_dice)
		# Create Interception
		event = Interception.new(
			speed_dice,
			card_resource,
			enemy_speed_dice,
			enemy_card,
			enemy_dice_intented
		)
		speed_dice.battle_event = event
		enemy_speed_dice.battle_event = event
	return event

## Check if enemy dice is targeting back this dice
func is_targeting_back(
	speed_dice: SpeedDice, enemy_speed_dice: SpeedDice
) -> bool:
	var result: bool
	if is_instance_of(enemy_speed_dice.battle_event, OnesideAttack):
		result = (
			enemy_speed_dice.battle_event.target_speed_dice.id
			== speed_dice.id
		)
	elif is_instance_of(enemy_speed_dice.battle_event, Clash):
		# If event is a Clash, search this dice in both targets
		result = (
			enemy_speed_dice.battle_event.speed_dice_a.enemy_dice_targeting.id
			== speed_dice.id
			or enemy_speed_dice.battle_event.speed_dice_b.enemy_dice_targeting.id
			== speed_dice.id
		)
	return result

## Remove Battle Event
func remove_battle_event(speed_dice: SpeedDice) -> void:
	var battle_event: Event = speed_dice.battle_event
	if battle_event:
		if is_instance_of(battle_event, OnesideAttack):
			battle_event.clear_speed_dices_references()
		elif is_instance_of(battle_event, Interception):
			rollback_interception(speed_dice)
		elif is_instance_of(battle_event, Clash):
			rollback_clash(speed_dice)
		event_queue.remove(battle_event)

## Rollback Clash
func rollback_clash(speed_dice: SpeedDice) -> void:
	var battle_event: Event = speed_dice.battle_event
	var oneside_attack_data: Dictionary = (
		battle_event.derive_oneside_attack(speed_dice)
	)
	battle_event.clear_speed_dices_references()
	create_battle_event(
		oneside_attack_data['attacker_speed_dice'],
		oneside_attack_data['enemy_speed_dice'],
		oneside_attack_data['card_resource']
	)

## Rollback Interception
func rollback_interception(speed_dice: SpeedDice) -> void:
	var battle_event: Interception = speed_dice.battle_event
	var enemy_speed_dice: SpeedDice = battle_event.target_speed_dice
	var enemy_dice_intended: SpeedDice = enemy_speed_dice.enemy_dice_intended
	var enemy_card: CardResource = battle_event.get_card_of_speed_dice(
		enemy_speed_dice
	)
	battle_event.clear_speed_dices_references()
	create_battle_event(
		enemy_speed_dice,
		enemy_dice_intended,
		enemy_card
	)
