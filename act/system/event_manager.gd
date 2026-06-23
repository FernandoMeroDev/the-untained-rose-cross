class_name EventManager extends RefCounted

signal battle_event_removed(speed_dice: SpeedDice)

## Selected Sound
var selected: AudioStreamPlayer

# Event Queue
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
	print('/* --- Create Event')
	print(
		speed_dice.parent_actor.actor_name
		+ "'s dice "
		+ str(speed_dice.id)
		+ ' targeting '
		+ enemy_speed_dice.parent_actor.actor_name
		+ "'s dice "
		+ str(enemy_speed_dice.id)
	)
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
	if is_instance_of(battle_event, OnesideAttack):
		battle_event.clear_speed_dices_references()
	elif is_instance_of(battle_event, Clash):
		var oneside_attack_data: Dictionary = (
			battle_event.derive_oneside_attack(speed_dice)
		)
		battle_event.clear_speed_dices_references()
		create_battle_event(
			oneside_attack_data['attacker_speed_dice'],
			oneside_attack_data['enemy_speed_dice'],
			oneside_attack_data['card_resource']
		)

func create(
	attacker_dice: SpeedDice, 
	target_dice: SpeedDice, 
	card_resource: CardResource
):
	if target_dice.event:
		if is_targeting_back(target_dice, attacker_dice):
			arrange_clash(attacker_dice, target_dice, card_resource)
		else:
			if attacker_dice.value > target_dice.value:
				create_interception(
					attacker_dice,
					target_dice,
					card_resource
				)
			else:
				arrange_oneside(attacker_dice, target_dice, card_resource)
	else:
		arrange_oneside(attacker_dice, target_dice, card_resource)

func remove(event: Event, remove_by = null):
	if is_instance_of(event, Interception):
		rollback_interception(event)
	elif is_instance_of(event, Clash):
		var references = get_oneside_references(event, remove_by)
		event.clear()
		# Restore old OneSide attack
		create(
			references['attacker_dice'],
			references['target_dice'],
			references['card_resource'],
		)
	elif is_instance_of(event, OnesideAttack):
		event.clear()

func get_oneside_references(event, remove_by) -> Dictionary:
	var attacker_dice = event.dice_b if(
			remove_by.id == event.dice_a.id
		) else event.dice_a
	return {
		"attacker_dice": attacker_dice,
		"target_dice": event.dice_a if(
				attacker_dice.id == event.dice_b.id
			) else event.dice_b,
		"card_resource": event.get_card(attacker_dice.id)
	}

func arrange_oneside(
	attacker_dice: SpeedDice, 
	target_dice: SpeedDice, 
	card_resource: CardResource
) -> void:
	event_queue.add(
		OnesideAttack.new(attacker_dice, target_dice, card_resource)
	)

func arrange_clash(
	attacker_dice: SpeedDice, 
	target_dice: SpeedDice, 
	card_resource: CardResource,
) -> void:
	var target_card_resource = target_dice.event.get_card(target_dice.id)
	var old_event = target_dice.event
	event_queue.remove(old_event)
	old_event.clear()
	event_queue.add(
		Clash.new(
			target_dice, 
			target_card_resource,
			attacker_dice,
			card_resource
		)
	)

func create_interception(
	attacker_dice: SpeedDice, 
	target_dice: SpeedDice, 
	card_resource: CardResource
) -> void:
	# Condiciones: El dado objetivo tiene un evento
	# 				El dado atacante supera la velocidad del objetivo
	# Guarda la intencion del objetivo
	target_dice.intent = target_dice.targeting
	# Si El objetivo estaba haciendo oneside
	if(
		is_instance_of(target_dice.event, OnesideAttack)
		or is_instance_of(target_dice.event, Clash)
	):
		# Obtenemos la carta del objetivo antes de eliminar el evento
		var target_card_resource = target_dice.event.get_card(target_dice.id)
		# Eliminamos las referencias del oneside/clash en los dados involucrados
		remove(target_dice.event, target_dice)
		# Creamos un clash de interception [Interception extends Clash]
		arrange_interception(
			attacker_dice, 
			target_dice, 
			card_resource,
			target_card_resource
		)
	# Sino Si El objetivo estaba siendo interceptado:
	elif is_instance_of(target_dice.event, Interception):
		# Por ahora crea un oneside
		arrange_oneside(attacker_dice, target_dice, card_resource)
		# Luego se podria implementar la intercepcion multiple que permite
		# seleccionar atacante con el TAB

func arrange_interception(
	attacker_dice: SpeedDice, 
	target_dice: SpeedDice, 
	card_resource: CardResource,
	target_card_resource: CardResource,
) -> void:
	event_queue.add(
		Interception.new(
			target_dice, 
			target_card_resource,
			attacker_dice,
			card_resource
		)
	)

func rollback_interception(event: Interception):
	var card_resource = event.get_card(event.target_dice.id)
	var target_dice = event.target_dice
	event.clear()
	event_queue.remove(event)
	create(
		target_dice, 
		target_dice.intent,
		card_resource
	)
