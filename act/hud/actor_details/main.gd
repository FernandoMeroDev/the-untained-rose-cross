extends Control


var actors: Node2D

## Valid values:
## 'area2d' | 'control'
var hover_tracer = 'area2d'

var actor_hovered = null

var actor_control_hovered = null

## Valid status values
enum States { HIDE, VISIBLE, MOVING_UP, MOVING_DOWN, SELECTED }

var panels = {
	'left': {
		'node': null,
		'status': States.HIDE,
		'tween': null,
		'actor_id': null,
		'original_position': null
	},
	'right': {
		'node': null,
		'status': States.HIDE,
		'tween': null,
		'actor_id': null,
		'original_position': null
	}
}

func _ready():
	panels['left']['node'] = $Left
	panels['right']['node'] = $Right
	panels['left']['original_position'] = $Left.position
	panels['right']['original_position'] = $Right.position

func init(actors_ref):
	actors = actors_ref

func _process(_delta):
	process_actor_hovered()

func process_actor_hovered():
	var current_actor_hovered = get_actor_under_mouse()
	if current_actor_hovered:
		if actor_hovered:
			if actor_hovered.id != current_actor_hovered.id:
				actor_hovered = current_actor_hovered
		else:
			actor_hovered = current_actor_hovered
			show_details(actor_hovered.id)
	else:
		if actor_hovered:
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
	if status == States.HIDE:
		if tween: tween.kill()
		tween = create_tween()
		panel['tween'] = tween
		panel['status'] = States.MOVING_DOWN
		set_actor_details(node, actor)
		var new_position = panel['original_position'] + Vector2(0, node.size.y)
		tween.tween_property(node, "position", new_position, 0.3)
		tween.finished.connect(func():
			if panel['status'] != States.SELECTED:
				panel['status'] = States.VISIBLE
		)
		$"../Actors".focus_actor(actor.id)
		actor.focus_self()
		panel['actor_id'] = actor.id
	elif status == States.MOVING_UP or status == States.MOVING_DOWN:
		if tween: tween.kill()
		panel['status'] = States.VISIBLE
		set_actor_details(node, actor)
		panel['node'].position = panel['original_position'] + Vector2(0, node.size.y)
		$"../Actors".focus_actor(actor.id)
		actor.focus_self()
		panel['actor_id'] = actor.id

func hide_details(id):
	var actor = actors.find(id)
	var panel = panels[actor.team]
	var tween: Tween = panel['tween']
	var status = panel['status']
	if status == States.VISIBLE or status == States.MOVING_DOWN:
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
		$"../Actors".unfocus_actor(actor.id)
		actor.unfocus_self()
		panel['actor_id'] = null

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
	var panel = panels[actor.team]
	var status = panel['status']
	if status != States.SELECTED:
		panel['status'] = States.SELECTED
		$SelectActor.play()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		for side in ['left', 'right']:
			var panel = panels[side]
			if panel['status'] == States.SELECTED:
				panel['status'] = States.VISIBLE
				hide_details(panel['actor_id'])
				if actor_hovered:
					if (
						actor_hovered.team == side
						and panel['actor_id'] != actor_hovered.id
					):
						show_details(actor_hovered.id)
			
