extends Control

const ActorControl = preload("res://act/hud/actors/actor_control/actor_control.gd")

## Turn Manager reference
var turn_manager: TurnManager

# --- Right Click Pressed Event Handler
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		$Left.handle_right_click_pressed()
		$Right.handle_right_click_pressed()

# --- Actor Control Events Observers
func _on_actor_control_pressed(control: ActorControl) -> void:
	handle_actor_pressed(control.parent_actor)

func _on_actor_control_mouse_entered(control: ActorControl) -> void:
	handle_actor_mouse_entered(control.parent_actor)

func _on_actor_control_mouse_exited(control: ActorControl) -> void:
	handle_actor_mouse_exited(control.parent_actor)

# --- Actor Events Observers
func _on_actor_pressed(actor: Actor) -> void:
	handle_actor_pressed(actor)

func _on_actor_mouse_entered(actor: Actor) -> void:
	handle_actor_mouse_entered(actor)

func _on_actor_mouse_exited(actor: Actor) -> void:
	handle_actor_mouse_exited(actor)

# --- Actor Speed Dices Events Observers
func _on_speed_dice_pressed(speed_dice: SpeedDice) -> void:
	handle_actor_pressed(speed_dice.parent_actor)

func _on_speed_dice_mouse_entered(speed_dice: SpeedDice) -> void:
	handle_actor_mouse_entered(speed_dice.parent_actor)

func _on_speed_dice_mouse_exited(speed_dice: SpeedDice) -> void:
	handle_actor_mouse_exited(speed_dice.parent_actor)

func init():
	$Left.init(turn_manager.Teams.LEFT)
	$Right.init(turn_manager.Teams.RIGHT)

# --- Events Handlers
func handle_actor_mouse_entered(actor: Actor) -> void:
	match actor.team:
		turn_manager.Teams.LEFT:
			$Left.handle_actor_mouse_entered(actor)
		turn_manager.Teams.RIGHT:
			$Right.handle_actor_mouse_entered(actor)

func handle_actor_mouse_exited(actor: Actor) -> void:
	match actor.team:
		turn_manager.Teams.LEFT:
			$Left.handle_actor_mouse_exited(actor)
		turn_manager.Teams.RIGHT:
			$Right.handle_actor_mouse_exited(actor)

func handle_actor_pressed(actor: Actor) -> void:
	match actor.team:
		turn_manager.Teams.LEFT:
			$Left.handle_actor_pressed(actor)
		turn_manager.Teams.RIGHT:
			$Right.handle_actor_pressed(actor)

func load_card(card_resource: CardResource, side: String):
	var card: Control = get_node(side.capitalize() + '/Card')
	card.load_card(card_resource)
	card.show()

func unload_card(team: String):
	var card: Control = get_node(team.capitalize() + '/Card')
	card.unload_card()
	card.hide()
