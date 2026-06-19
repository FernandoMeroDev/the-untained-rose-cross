class_name SpeedDice extends TextureButton

signal speed_dice_mouse_entered(dice)

signal dice_mouse_exited(dice)

signal dice_pressed(dice)

enum States { UNDETERMINED, DETERMINED, FOCUSED }

## Reference to owner actor
var parent_actor: Actor

## Unique Dice ID. Following this pattern:
## For Actor ID 1, Dices ID: 1001, 1002, 1003... etc
var id: int

## Speed Dice Value
var value: int

## Speed Dice current status
var status: States = States.UNDETERMINED

## Speed Dice textures
var textures: Dictionary[String, Texture];

## Animation (Tween) for undetermined status
var animation_shake: Tween

## Battle Event living in this dice
var battle_event: Event

## Target enemy dice intended
var enemy_dice_intended: SpeedDice

## Actually enemy dice targeting
var enemy_dice_targeting: SpeedDice

## Enemy dices targeting this dice
var targeted_by_enemies: Array[SpeedDice] = []

var dependencies = {}

func init(speed, dice_id: int, speed_dice_dependencies):
	dependencies = speed_dice_dependencies
	id = dice_id
	$Random/Interval.timeout.connect(change_random_number)
	$Number.text = str(speed['min']) + '~' + str(speed['max'])
	init_animate_shake()
	init_textures()

func init_animate_shake(duration = 1.8, strength = 2.0):
	var original_pos = $Number.position
	var tween = $Number.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	var steps = 6
	for i in steps:
		var offset = Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		tween.tween_property($Number, "position", original_pos + offset, duration / steps)
	tween.tween_property($Number, "position", original_pos, duration / steps)
	tween.set_loops()
	animation_shake = tween

## Positionate dice relative to its siblings and parent Actor
func self_positionate(
	i: int, actor_height: float, total_dices_count: int
) -> void:
	position.y -= actor_height / 2
	position.y -= get_rect().size.y
	position.x -= (get_rect().size.x * total_dices_count) / 2
	position.x += i * get_rect().size.x

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
	$Selected.play()

func unfocus() -> void:
	self.status = self.States.DETERMINED
	texture_normal = textures['normal']

func _on_mouse_entered() -> void:
	speed_dice_mouse_entered.emit(self)

func _on_mouse_exited() -> void:
	dice_mouse_exited.emit(self)

func _on_pressed() -> void:
	dice_pressed.emit(self)

func _gui_input(input_event):
	if input_event is InputEventMouseButton:
		if input_event.button_index == MOUSE_BUTTON_RIGHT and input_event.pressed:
			# Handle Input Event: 
			# speed_dice_mouse_button_right_pressed
			pass
			## Si hay evento y estamos en el turno actual
			#if event != null and current_turn():
				## Remueve el evento del dado de velocidad
				#var card: CardResource = event.get_card(id)
				#parent_actor.hand.append(card)
				#dependencies['actor_details'].unload_card(parent_actor.team)
				## Handle Enemy dice unset
				#if (
					#dependencies['hand'].enemy_status 
					#== dependencies['hand'].EnemyStates.DICE_FOCUSED
				#):
					#dependencies['actor_details'].unload_card(
						#'left' if parent_actor.team == 'right' else 'right'
					#)
				#dependencies['system'].removeBattleEvent(event, parent_actor)
				#dependencies['hand'].clear_hand()
				#dependencies['hand'].show_hand(parent_actor)
				#if dependencies['hand'].status == dependencies['hand'].States.IDLE:
					#dependencies['arrows'].remove_event_arrows()

#func current_turn():
	#return dependencies['system'].current_team == parent_actor.team
