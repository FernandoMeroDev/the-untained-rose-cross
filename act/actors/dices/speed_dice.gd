class_name SpeedDice extends TextureButton

signal dice_mouse_entered(dice)

signal dice_mouse_exited(dice)

signal dice_pressed(dice)

enum States { UNDETERMINED, DETERMINED, FOCUSED }

var parent_actor

var id

var value = null

var status = States.UNDETERMINED

var textures: Dictionary[String, Texture];

var animation_shake: Tween

## Battle Event living in this dice
var event: Event = null

## target intent
var intent: SpeedDice = null

var targeting: SpeedDice = null

var targeted_by: Array[SpeedDice] = []

var dependencies = {}

func init(speed, dice_id, speed_dice_dependencies):
	dependencies = speed_dice_dependencies
	id = dice_id
	status = States.UNDETERMINED
	$Number.text = str(speed['min']) + '~' + str(speed['max'])
	$Random/Interval.timeout.connect(change_random_number)
	init_animate_shake()
	init_textures()

func init_animate_shake(duration = 1.8, strength = 2.0):
	var original_pos = self.position
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	var steps = 6
	for i in steps:
		var offset = Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		tween.tween_property(self, "position", original_pos + offset, duration / steps)
	tween.tween_property(self, "position", original_pos, duration / steps)
	tween.set_loops()
	animation_shake = tween

func init_textures():
	textures['normal'] = texture_normal
	textures['active'] = preload("res://media/actors/dices/speed/active.png")

func change_random_number():
	if status == States.UNDETERMINED:
		var n = int($Random.text)
		if n == 9: n = 0
		n += 1
		$Random.text = str(n)

func set_speed(n):
	value = n
	animation_shake.kill()
	status = States.DETERMINED
	$Number.text = str(value)

func focus() -> void:
	self.status = self.States.FOCUSED
	texture_normal = textures['active']
	dependencies['sfx']['selected'].play()

func unfocus() -> void:
	self.status = self.States.DETERMINED
	texture_normal = textures['normal']

func _on_mouse_entered() -> void:
	dice_mouse_entered.emit(self)

func _on_mouse_exited() -> void:
	dice_mouse_exited.emit(self)

func _on_pressed() -> void:
	dice_pressed.emit(self)

func _gui_input(input_event):
	if input_event is InputEventMouseButton:
		if input_event.button_index == MOUSE_BUTTON_RIGHT and input_event.pressed:
			# Si hay evento y estamos en el turno actual
			if event != null and current_turn():
				# Remueve el evento del dado de velocidad
				var card: CardResource = event.get_card(id)
				parent_actor.hand.append(card)
				dependencies['actor_details'].unload_card(parent_actor.team)
				# Handle Enemy dice unset
				if (
					dependencies['hand'].enemy_status 
					== dependencies['hand'].EnemyStates.DICE_FOCUSED
				):
					dependencies['actor_details'].unload_card(
						'left' if parent_actor.team == 'right' else 'right'
					)
				dependencies['system'].removeBattleEvent(event, parent_actor)
				dependencies['hand'].clear_hand()
				dependencies['hand'].show_hand(parent_actor)
				if dependencies['hand'].status == dependencies['hand'].States.IDLE:
					dependencies['arrows'].remove_event_arrows()

func current_turn():
	return dependencies['system'].current_team == parent_actor.team
