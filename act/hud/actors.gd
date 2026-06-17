extends Control


var dependencies = {}

func init(config, actor_dependencies):
	dependencies = actor_dependencies
	init_team(config, 'left')
	init_team(config, 'right')

func init_team(config, team):
	var i = 1 if team == 'left' else 6
	for actor_data in config['teams'][team]:
		var actor: TextureRect = get_node("Actor" + str(i))
		var avatar: TextureRect = actor.get_node('Portrait/Avatar')
		avatar.texture = load('res://media/actors/sprites/' + actor_data['code'] + '/' + 'default.png')
		if team == 'right': avatar.flip_h = true
		actor.show()
		actor.get_node('Name').text = actor_data['name']
		var max_hp = int(actor_data['stats']['max_hp'])
		actor.get_node('HP').text = str(max_hp)
		var bar: TextureProgressBar = actor.get_node('HealthBar')
		bar.max_value = max_hp
		bar.value = max_hp
		actor.actor_id = int(actor_data['id'])
		actor.parent = self
		actor.get_node('Box').mouse_entered.connect(_on_actor_mouse_entered.bind(actor))
		actor.get_node('Box').mouse_exited.connect(_on_actor_mouse_exited.bind(actor))
		dependencies['scenary.actors'].find(actor_data['id']).actor_control = actor
		i += 1

func _on_actor_mouse_entered(control):
	dependencies['actor_details'].hover_tracer = 'control'
	dependencies['actor_details'].show_details(control.actor_id)
	dependencies['actor_details'].actor_control_hovered = control

func _on_actor_mouse_exited(control):
	dependencies['actor_details'].hover_tracer = 'area2d'
	dependencies['actor_details'].hide_details(control.actor_id)
	dependencies['actor_details'].actor_control_hovered = null

func find_actor(id):
	for actor: TextureRect in get_children():
		if actor.actor_id == id:
			return actor

func focus_actor(id):
	var actor = find_actor(id)
	actor.self_modulate = Color(1.00, 1.00, 1.00)
	actor.get_node('Portrait/Cover').self_modulate = Color(1.00, 1.00, 1.00)
	actor.get_node('Name').self_modulate = Color(0, 0.26, 1)

func unfocus_actor(id):
	var actor = find_actor(id)
	actor.self_modulate = Color(0, 0, 0)
	actor.get_node('Portrait/Cover').self_modulate = Color(0, 0, 0)
	actor.get_node('Name').self_modulate = Color(1, 1, 1)

func select_actor(id):
	dependencies['actor_details'].select_actor(id)

func outline_actor(id):
	var actor: TextureRect = find_actor(id)
	actor.scale = Vector2(1.1, 1.1)

func unoutline_actor(id):
	var actor: TextureRect = find_actor(id)
	actor.scale = Vector2(1, 1)
