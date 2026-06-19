extends Control


signal card_focused(dice)

signal card_unfocused()

enum States { IDLE, DICE_FOCUSED, CARD_FOCUSED }

enum EnemyStates { IDLE, DICE_FOCUSED }

var status = States.IDLE

var enemy_status = EnemyStates.IDLE

## Is showing the hand in the screen?
var active: bool = false

## Actor currently focused
## @var Area2D | null
var focused_actor: Variant = null

## Dice currently focused
## @var Node2D | null
var focused_dice: Variant = null

## Card currently focused
## @var Button | null
var focused_card: Variant = null

## Enemy dice currently focused
## @var Node2D | null
var focused_enemy_dice: Variant = null

var dependencies = {}

var card_scene: PackedScene

func _ready():
	card_scene = preload('res://act/hud/hand/card/card.tscn')

func init(hand_dependencies):
	dependencies = hand_dependencies

func current_turn(actor):
	return actor.team == dependencies['system'].current_team

func handle_dice_mouse_entered(actor, dice) -> void:
	if status == States.IDLE and current_turn(actor):
		show_hand(actor)
		if dice.targeting:
			dependencies['actor_details'].load_card(
				dice.event.get_card(dice.id),
				actor.team
			)
	# Si la mano tiene un dado enfocado o una carta enfocada
	elif status == States.DICE_FOCUSED or status == States.CARD_FOCUSED:
		# Si el dado al que entro es diferente al dado enfocado
		if focused_dice.id != dice.id and current_turn(actor):
			# Y el dado enfocado tiene objetivo
			if focused_dice.targeting:
				# Remueve la carta temporalmente
				dependencies['actor_details'].unload_card(focused_actor.team)
			# Si el dado al que entro tiene objetivo
			if dice.targeting:
				#  Carga temporalmente la carta del dado al que entro
				dependencies['actor_details'].load_card(
					dice.event.get_card(dice.id),
					actor.team
				)
	# ------ [Manejar el estado del dado enemigo]
	# Si se esta enfocando un dado enemigo
	# y el dado al que entro es del enemigo
	if not current_turn(dice.parent_actor):
		if enemy_status == EnemyStates.IDLE:
			if dice.targeting:
				dependencies['actor_details'].load_card(
					dice.event.get_card(dice.id),
					actor.team
				)
		elif enemy_status == EnemyStates.DICE_FOCUSED:
			# Y el dado enfocado tiene objetivo
			if focused_enemy_dice.targeting and dice.id != focused_enemy_dice.id:
				# Remueve la carta temporalmente
				dependencies['actor_details'].unload_card(
					focused_enemy_dice.parent_actor.team
				)
				# Carga la carta en hover temporalmente si hay
				if dice.targeting:
					dependencies['actor_details'].load_card(
						dice.event.get_card(dice.id),
						actor.team
					)
			elif not focused_enemy_dice.targeting:
				# Carga la carta en hover temporalmente si hay
				if dice.targeting:
					dependencies['actor_details'].load_card(
						dice.event.get_card(dice.id),
						actor.team
					)

func handle_dice_mouse_exited(actor, dice) -> void:
	if status == States.IDLE:
		if current_turn(actor): clear_hand()
		if dice.targeting and current_turn(actor):
			dependencies['actor_details'].unload_card(actor.team)
	# Si la mano tiene un dado enfocado 
	elif status == States.DICE_FOCUSED or status == States.CARD_FOCUSED:
		# Y el dado al que entro es diferente al dado enfocado 
		# y no es un dado enemigo
		if focused_dice.id != dice.id and current_turn(actor):
			if dice.targeting:
				# Si el dado del que salio tiene objetivo
				# Remueve la carta que mostraste temporalmente
				dependencies['actor_details'].unload_card(actor.team)
			# Si el dado enfocado tiene objetivo
			if focused_dice.targeting:
				# Reestablece la carta que removiste temporalmente
				dependencies['actor_details'].load_card(
					focused_dice.event.get_card(focused_dice.id),
					focused_actor.team
				)
	# ------ [Manejar el estado del dado enemigo]
	# Si se esta enfocando un dado enemigo
	# y el dado del que salio es del enemigo
	if not current_turn(dice.parent_actor):
		if enemy_status == EnemyStates.DICE_FOCUSED:
			# Y el dado del que salio es diferente al dado enfocado
			if focused_enemy_dice.id != dice.id:
				if dice.targeting:
					# Si el dado del que salio tiene objetivo
					# Remueve la carta que mostraste temporalmente
					dependencies['actor_details'].unload_card(actor.team)
				# Si el dado enemigo enfocado tiene objetivo
				if focused_enemy_dice.targeting:
					# Reestablece la carta que removiste temporalmente
					dependencies['actor_details'].load_card(
						focused_enemy_dice.event.get_card(focused_enemy_dice.id),
						focused_enemy_dice.parent_actor.team
					)
		else:
			if dice.targeting:
				# Si el dado del que salio tiene objetivo
				# Remueve la carta que mostraste
				dependencies['actor_details'].unload_card(actor.team)

func show_hand(actor):
	active = true
	var hand: Array[CardResource] = actor.hand
	# Layout adjustments
	var cards_count: int = len(hand)
	var card_width: int = card_scene.instantiate().size.x
	var gap: int = 5
	var hand_width: float = cards_count * card_width + (cards_count - 1) * gap
	var start_x: float = (size.x - hand_width) / 2
	# Instanciate Cards
	var i: int = 0
	for card_resource in hand:
		var card = card_scene.instantiate()
		card.init(card_resource)
		var card_position = Vector2(
			start_x + i * (card_width + gap),
			card.position.y
		)
		get_tree().create_tween().tween_property(
			card, "position", card_position, 0.25
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		add_child(card)
		card.selected.connect(handle_card_mouse_pressed)
		card.card_mouse_entered.connect(handle_card_mouse_entered)
		i += 1

func clear_hand() -> void:
	active = false
	for card in get_children():
		remove_child(card)

func handle_dice_pressed(actor, dice) -> void:
	if current_turn(actor):
		if status == States.IDLE:
			focused_actor = actor
			focused_dice = dice
			if not active: show_hand(actor)
			dice.focus()
			status = States.DICE_FOCUSED
		elif status == States.DICE_FOCUSED:
			if focused_actor == actor:
				if focused_dice == dice:
					exit_dice_focus()
					status = States.IDLE
				else:
					change_dice_focus(dice)
			else:
				focused_actor = actor
				change_dice_focus(dice)
				clear_hand()
				show_hand(actor)
	else:
		if enemy_status == EnemyStates.IDLE:
			focused_enemy_dice = dice
			dice.focus()
			enemy_status = EnemyStates.DICE_FOCUSED
		elif enemy_status == EnemyStates.DICE_FOCUSED:
			if focused_enemy_dice.parent_actor == actor:
				if focused_enemy_dice == dice:
					exit_enemy_dice_focus()
					enemy_status = EnemyStates.IDLE
				else:
					change_enemy_dice_focus(dice)
			else:
				change_enemy_dice_focus(dice)
		if status == States.CARD_FOCUSED and focused_dice.targeting:
			# [Remove Old Battle Event]
			var card: CardResource = focused_dice.event.get_card(focused_dice.id)
			focused_dice.parent_actor.hand.append(card)
			dependencies['actor_details'].unload_card(focused_dice.parent_actor.team)
			dependencies['system'].removeBattleEvent(focused_dice.event)
			# [Create New Battle Event]
			createBattleEvent(dice)
		elif status == States.CARD_FOCUSED and not focused_dice.targeting:
			createBattleEvent(dice)

func exit_enemy_dice_focus():
	focused_enemy_dice.unfocus()
	focused_enemy_dice = null

func exit_dice_focus():
	focused_dice.unfocus()
	focused_dice = null

func change_dice_focus(dice):
	focused_dice.unfocus()
	focused_dice = dice
	focused_dice.focus()
	dependencies['arrows'].remove_event_arrows()

func change_enemy_dice_focus(dice):
	focused_enemy_dice.unfocus()
	focused_enemy_dice = dice
	focused_enemy_dice.focus()
	dependencies['arrows'].remove_event_arrows()

func handle_card_mouse_entered(card: Button) -> void:
	if status == States.DICE_FOCUSED:
		card.focus()

func handle_card_mouse_pressed(card: Button) -> void:
	if status == States.DICE_FOCUSED:
		card.focused = true
		card.focus()
		focused_card = card
		card_focused.emit(focused_dice)
		if focused_dice.event:
			dependencies['actor_details'].unload_card(focused_actor.team)
		dependencies['actor_details'].load_card(
			focused_card.resource,
			focused_actor.team
		)
		status = States.CARD_FOCUSED

func exit_card_focus():
	if status == States.CARD_FOCUSED:
		focused_card.focused = false
		focused_card.unfocus()
		card_unfocused.emit()
		focused_card = null

func createBattleEvent(dice):
	# Arrange an Event
	dependencies['system'].createBattleEvent(focused_dice, dice, focused_card.resource)
	# Hide Card from the panel
	dependencies['actor_details'].unload_card(focused_actor.team)
	# Remove card from the hand
	focused_actor.hand.erase(focused_card.resource)
	focused_actor.deck.append(focused_card.resource)
	# Exit Hand focus
	exit_card_focus()
	status = States.DICE_FOCUSED
	exit_dice_focus()
	status = States.IDLE
	clear_hand()
	dependencies['arrows'].remove_event_arrows()
