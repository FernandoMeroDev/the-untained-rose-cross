extends Control

const ActorControl = preload("res://act/hud/actors/actor_control/actor_control.gd")

var actors: Node2D

## Valid values:
## 'area2d' | 'control'
var hover_tracer = 'area2d'

var actor_hovered = null

## Actor Control currently hovered
var actor_control_hovered: ActorControl = null

## Valid status values
enum States { HIDE, VISIBLE, MOVING_UP, MOVING_DOWN, OVERPOSITION }

var panels = {
	'left': {
		'node': null,
		'status': States.HIDE,
		'tween': null,
		'actor_id': null,
		'original_position': null,
		'selected': null
	},
	'right': {
		'node': null,
		'status': States.HIDE,
		'tween': null,
		'actor_id': null,
		'original_position': null,
		'selected': null
	}
}

var dependencies = {}

func _on_actor_control_pressed(control: ActorControl):
	select_actor(control.actor_id)
	
func _on_actor_control_mouse_entered(control: ActorControl):
	hover_tracer = 'control'
	show_details(control.actor_id)
	actor_control_hovered = control

func _on_actor_control_mouse_exited(control: ActorControl):
	hover_tracer = 'area2d'
	hide_details(control.actor_id)
	actor_control_hovered = null

func _ready():
	panels['left']['node'] = $Left
	panels['right']['node'] = $Right
	panels['left']['original_position'] = $Left.position
	panels['right']['original_position'] = $Right.position

func init(actor_details_dependencies):
	actors = actor_details_dependencies['actors']
	dependencies = actor_details_dependencies
	$Left/Card.team = 'left'
	$Right/Card.team = 'right'

func _process(_delta):
	process_actor_hovered()

func process_actor_hovered():
	var current_actor_hovered = get_actor_under_mouse()
	if current_actor_hovered:
		if actor_hovered:
			if actor_hovered.id != current_actor_hovered.id:
				actor_hovered = current_actor_hovered
			else:
				var panel = panels[actor_hovered.team]
				if panel['status'] == States.HIDE:
					show_details(actor_hovered.id)
		else:
			actor_hovered = current_actor_hovered
			show_details(actor_hovered.id)
	else:
		if actor_hovered:
			var panel = panels[actor_hovered.team]
			var selected = panel['selected']
			if selected:
				panel['status'] = States.OVERPOSITION
				$"../Actors".unoutline_actor(actor_hovered.id)
				set_actor_details(panel['node'], selected)
			else:
				hide_details(actor_hovered.id)
			actor_hovered = null

func get_actor_under_mouse():
	if hover_tracer == 'area2d':
		return get_area2d_hovered()
	elif hover_tracer == 'control':
		return actors.find(actor_control_hovered.actor_id)

func get_area2d_hovered():
	var point = PhysicsPointQueryParameters2D.new()
	point.collide_with_areas = true
	point.position = get_global_mouse_position()
	var results = get_world_2d().direct_space_state.intersect_point(point, 1)
	for result in results:
		var collider = result['collider']
		if collider.is_in_group('actors'):
			return collider
	return null

func show_details(id):
	var actor = actors.find(id)
	var panel = panels[actor.team]
	var status = panel['status']
	var node: TextureRect = panel['node']
	var tween: Tween = panel['tween']
	var selected = panel['selected']
	if status == States.HIDE or status == States.OVERPOSITION:
		if tween: tween.kill()
		tween = create_tween()
		panel['tween'] = tween
		panel['status'] = States.MOVING_DOWN
		set_actor_details(node, actor)
		var new_position = panel['original_position'] + Vector2(0, node.size.y)
		tween.tween_property(node, "position", new_position, 0.3)
		tween.finished.connect(func():
			if panel['status'] != States.OVERPOSITION:
				panel['status'] = States.VISIBLE
		)
		$"../Actors".outline_actor(actor.id)
		panel['actor_id'] = actor.id
	elif status == States.MOVING_UP or status == States.MOVING_DOWN:
		if tween: tween.kill()
		panel['status'] = States.VISIBLE
		set_actor_details(node, actor)
		panel['node'].position = panel['original_position'] + Vector2(0, node.size.y)
		$"../Actors".outline_actor(actor.id)
		panel['actor_id'] = actor.id
	elif status == States.VISIBLE and selected:
		set_actor_details(node, actor)
		$"../Actors".outline_actor(actor.id)

func hide_details(id):
	var actor = actors.find(id)
	var panel = panels[actor.team]
	var tween: Tween = panel['tween']
	var status = panel['status']
	var selected = panel['selected']
	if (status == States.VISIBLE or status == States.MOVING_DOWN) and not selected:
		if tween: tween.kill()
		tween = create_tween()
		panel['tween'] = tween
		panel['status'] = States.MOVING_UP
		var node = panel['node']
		var new_position = panel['original_position'] - Vector2(0, node.size.y)
		tween.tween_property(node, "position", new_position, 0.3)
		tween.finished.connect(func():
			panel['status'] = States.HIDE
		)
		$"../Actors".unoutline_actor(actor.id)
		panel['actor_id'] = null
	elif status == States.VISIBLE and selected:
		$"../Actors".unoutline_actor(actor.id)

func set_actor_details(node, actor):
	# Texture
	node.get_node('Portrait/Actor').texture = load('res://media/actors/sprites/' + actor.code + '/default.png')
	# Resistences
	for resistence: TextureRect in node.get_node('Resistences').get_children():
		var key = resistence.name.to_snake_case()
		var resistence_name = actor.resistences[key] + '_' + key # weak_pierce_damage
		resistence.tooltip_text = ''
		for word in resistence_name.split('_'):
			resistence.tooltip_text += word.capitalize() + ' '
		resistence.texture = load('res://media/icons/resistences/' + resistence_name + '.png')
	# Name
	node.get_node('Name/Text').text = actor.actor_name
	# HP Gauge
	var health: TextureProgressBar = node.get_node('Gauges/Health')
	health.max_value = actor.max_hp
	health.value = actor.hp
	health.get_node('Number').text = str(actor.hp)
	# RP Gauge
	var resist: TextureProgressBar = node.get_node('Gauges/Resist')
	resist.max_value = actor.max_resist
	resist.value = actor.resist
	resist.get_node('Number').text = str(actor.resist)

func select_actor(id):
	var actor = actors.find(id)
	var hand = dependencies['hand']
	var panel = panels[actor.team]
	var selected = panel['selected']
	# Prevents select another actor when the card is being focused
	if hand.status == hand.States.CARD_FOCUSED: return
	if selected:
		# Prevents select the same selected actor
		if selected.id == actor.id: return
		$"../Actors".unfocus_actor(selected.id)
		selected.unfocus_self()
	$"../Actors".focus_actor(actor.id)
	actor.focus_self()
	dependencies['sfx']['selected'].play()
	panel['selected'] = actor

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		var system = dependencies['system']
		var hand = dependencies['hand']
		var arrows = dependencies['arrows']
		for side in ['left', 'right']:
			var panel = panels[side]
			var selected = panel['selected']
			if selected:
				if hand.status == hand.States.IDLE:
					reset_panel(panel, selected, side)
					if hand.enemy_status == hand.EnemyStates.DICE_FOCUSED:
						hand.exit_enemy_dice_focus()
						hand.enemy_status = hand.EnemyStates.IDLE
				elif (
					hand.status == hand.States.DICE_FOCUSED
					and side == system.current_team
				):
					reset_panel(panel, selected, side)
					hand.exit_dice_focus()
					hand.clear_hand()
					arrows.remove_event_arrows()
					unload_card(side)
					hand.status = hand.States.IDLE
				elif (
					hand.status == hand.States.CARD_FOCUSED
					and side == system.current_team
				):
					hand.exit_card_focus()
					unload_card(side)
					if hand.focused_dice.event:
						load_card(
							hand.focused_dice.event.get_card(hand.focused_dice.id), 
							side
						)
					hand.status = hand.States.DICE_FOCUSED

func reset_panel(panel, selected, side):
	panel['selected'] = null
	$"../Actors".unfocus_actor(selected.id)
	selected.unfocus_self()
	panel['status'] = States.VISIBLE
	hide_details(selected.id)
	if actor_hovered:
		if actor_hovered.team == side:
			show_details(actor_hovered.id)

func load_card(card_resource: CardResource, side: String):
	var card: Control = get_node(side.capitalize() + '/Card')
	card.load_card(card_resource)
	card.show()

func unload_card(team: String):
	var card: Control = get_node(team.capitalize() + '/Card')
	card.unload_card()
	card.hide()
