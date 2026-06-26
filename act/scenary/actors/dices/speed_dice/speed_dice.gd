class_name SpeedDice extends TextureButton

signal speed_dice_right_click_pressed(speed_dice: SpeedDice)

signal speed_dice_pressed(speed_dice: SpeedDice)

signal speed_dice_mouse_entered(speed_dice: SpeedDice)

signal speed_dice_mouse_exited(speed_dice: SpeedDice)

#signal dice_pressed(dice)

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

## Battle Event living in this dice
var battle_event: Event

## Target enemy dice intended
var enemy_dice_intended: SpeedDice

## Actually enemy dice targeting
var enemy_dice_targeting: SpeedDice

## Enemy dices targeting this dice
var targeted_by_enemies: Array[SpeedDice] = []

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			speed_dice_right_click_pressed.emit(self)

func _on_mouse_entered() -> void:
	speed_dice_mouse_entered.emit(self)

func _on_mouse_exited() -> void:
	speed_dice_mouse_exited.emit(self)

func _on_pressed() -> void:
	speed_dice_pressed.emit(self)

func init(speed, dice_id: int) -> void:
	id = dice_id
	$Roulette.init()
	$Number.init(
		int(speed['min']),
		int(speed['max'])
	)
	init_textures()

func init_textures() -> void:
	textures['normal'] = texture_normal
	textures['active'] = preload("res://media/actors/dices/speed/active.png")

## Positionate dice relative to its siblings and parent Actor
func self_positionate(
	i: int, actor_height: float, total_dices_count: int
) -> void:
	position.y -= actor_height / 2
	position.y -= get_rect().size.y
	position.x -= (get_rect().size.x * total_dices_count) / 2
	position.x += i * get_rect().size.x

## Set Dice Speed to determine its value
func set_speed(speed_value: int) -> void:
	value = speed_value
	$Number.stop_animation_shaking()
	$Number.set_value(speed_value)
	$Roulette.stop()
	status = States.DETERMINED

## Focus Speed Dice
func focus() -> void:
	texture_normal = textures['active']
	$Selected.play()
	status = States.FOCUSED

## Unfocus Speed Dice
func unfocus() -> void:
	texture_normal = textures['normal']
	status = States.DETERMINED
