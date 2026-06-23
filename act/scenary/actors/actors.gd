extends Node2D

const ActorScene: PackedScene = preload("res://act/scenary/actors/actor.tscn")


func init(config: Dictionary, dependencies) -> Array[Actor]:
	var actors: Array[Actor]
	for team: String in ['left', 'right']:
		var positions: Array[Marker2D] = get_team_positions(team)
		var i: int = 0
		for actor_data: Dictionary in config['teams'][team]:
			var actor: Actor = ActorScene.instantiate() as Actor
			var position_node: Marker2D = positions[i]
			actor_data['team'] = team
			actor.init(actor_data, dependencies)
			add_child(actor)
			actor.global_position = position_node.global_position
			actor.flip_h_sprite(team == 'right')
			actor.add_to_group('actors')
			actors.append(actor)
			i += 1
	print('Inited Actors')
	return actors

## Search the Marker2D nodes of a team
func get_team_positions(team: String) -> Array[Marker2D]:
	var markers: Array[Marker2D]
	for node: Node in get_tree().get_nodes_in_group(team + '_team_positions'):
		markers.append(node as Marker2D)
	return markers

func find(id) -> Actor:
	var result: Actor
	for actor: Actor in get_children():
		if actor.id == id:
			result = actor
	return result

func roll_everyone_speed_dices():
	for actor in get_children():
		actor.roll_speed_dices()
