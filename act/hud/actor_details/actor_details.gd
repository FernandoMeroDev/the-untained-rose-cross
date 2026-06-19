extends Control

const ActorControl = preload("res://act/hud/actors/actor_control/actor_control.gd")

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

func init():
	$Left.init('left')
	$Right.init('right')

func handle_actor_mouse_entered(actor: Actor) -> void:
	match actor.team:
		'left':
			$Left.handle_actor_mouse_entered(actor)
		'right':
			$Right.handle_actor_mouse_entered(actor)

func handle_actor_mouse_exited(actor: Actor) -> void:
	match actor.team:
		'left':
			$Left.handle_actor_mouse_exited(actor)
		'right':
			$Right.handle_actor_mouse_exited(actor)

func handle_actor_pressed(actor: Actor) -> void:
	match actor.team:
		'left':
			$Left.handle_actor_pressed(actor)
		'right':
			$Right.handle_actor_pressed(actor)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		$Left.handle_right_click_pressed()
		$Right.handle_right_click_pressed()
		#var system = dependencies['system']
		#var hand = dependencies['hand']
		#var arrows = dependencies['arrows']
		#for side in ['left', 'right']:
			#var panel = panels[side]
			#var selected = panel['selected']
			#if selected:
				#if hand.status == hand.States.IDLE:
					#reset_panel(panel, selected, side)
					#if hand.enemy_status == hand.EnemyStates.DICE_FOCUSED:
						#hand.exit_enemy_dice_focus()
						#hand.enemy_status = hand.EnemyStates.IDLE
				#elif (
					#hand.status == hand.States.DICE_FOCUSED
					#and side == system.current_team
				#):
					#reset_panel(panel, selected, side)
					#hand.exit_dice_focus()
					#hand.clear_hand()
					#arrows.remove_event_arrows()
					#unload_card(side)
					#hand.status = hand.States.IDLE
				#elif (
					#hand.status == hand.States.CARD_FOCUSED
					#and side == system.current_team
				#):
					#hand.exit_card_focus()
					#unload_card(side)
					#if hand.focused_dice.event:
						#load_card(
							#hand.focused_dice.event.get_card(hand.focused_dice.id), 
							#side
						#)
					#hand.status = hand.States.DICE_FOCUSED

#func reset_panel(panel, selected, side):
	#panel['selected'] = null
	#$"../Actors".unfocus_actor(selected.id)
	#selected.unfocus_self()
	#panel['status'] = States.VISIBLE
	#hide_details(selected.id)
	#if actor_hovered:
		#if actor_hovered.team == side:
			#show_details(actor_hovered.id)

func load_card(card_resource: CardResource, side: String):
	var card: Control = get_node(side.capitalize() + '/Card')
	card.load_card(card_resource)
	card.show()

func unload_card(team: String):
	var card: Control = get_node(team.capitalize() + '/Card')
	card.unload_card()
	card.hide()
