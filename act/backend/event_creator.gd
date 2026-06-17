class_name EventCreator extends RefCounted

var eventQueue: EventQueue

func _init():
	eventQueue = EventQueue.new()

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

func is_targeting_back(target_dice, attacker_dice) -> bool:
	# Is the target dice targeting back the attacker?
	if is_instance_of(target_dice.event, OnesideAttack):
		return target_dice.event.target_dice.id == attacker_dice.id
	else:
		# Is instance of clash, check both dices
		return (
			target_dice.event.dice_a.targeting == attacker_dice
			or target_dice.event.dice_b.targeting == attacker_dice
		)

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
	eventQueue.add(
		OnesideAttack.new(attacker_dice, target_dice, card_resource)
	)

func arrange_clash(
	attacker_dice: SpeedDice, 
	target_dice: SpeedDice, 
	card_resource: CardResource,
) -> void:
	var target_card_resource = target_dice.event.get_card(target_dice.id)
	var old_event = target_dice.event
	eventQueue.remove(old_event)
	old_event.clear()
	eventQueue.add(
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
	eventQueue.add(
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
	eventQueue.remove(event)
	create(
		target_dice, 
		target_dice.intent,
		card_resource
	)
