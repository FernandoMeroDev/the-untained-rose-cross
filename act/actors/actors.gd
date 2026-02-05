extends Node2D


var init_config = {
	"sprite_scale": Vector2(0.55, 0.55)
}

func init(config, dependencies):
	init_team('left', config, dependencies)
	init_team('right', config, dependencies)
	print('Inited Actors')

func init_team(side, config, dependencies):
	var positions = get_tree().get_nodes_in_group(side + '_team_positions')
	var i = 0
	for actor_data in config['teams'][side]:
		var actor_scene = load("res://act/actors/actor.tscn")
		var actor: Area2D = actor_scene.instantiate()
		var position_node = positions[i]
		actor_data['team'] = side
		actor.init(actor_data, dependencies)
		actor.transform = actor.transform.scaled(init_config["sprite_scale"])
		add_child(actor)
		actor.global_position = position_node.global_position
		actor.get_node('Sprite').flip_h = side == 'right'
		actor.add_to_group('actors')
		i += 1

func find(id):
	for actor in get_children():
		if actor.id == id: return actor

func roll_speed_dices():
	for actor in get_children():
		actor.roll_speed_dice()
