extends Node2D

const ActorScene: PackedScene = preload("res://act/scenary/actors/actor.tscn")

func init(config: Dictionary) -> Array[Actor]:
	var actors: Array[Actor]
	for team: String in ['left', 'right']:
		var positions: Array[Marker2D] = get_team_positions(team)
		var i: int = 0
		for actor_data: Dictionary in config['teams'][team]:
			var actor: Actor = ActorScene.instantiate() as Actor
			var position_node: Marker2D = positions[i]
			actor_data['team'] = team
			actor.init(actor_data)
			add_child(actor)
			actor.global_position = position_node.global_position
			actor.flip_h(team == 'right')
			actor.add_to_group('actors')
			actor.add_to_group(team + '_team_actors')
			actors.append(actor)
			i += 1
	#print('Inited Actors')
	return actors

func get_team_actors(team: TurnManager.Teams) -> Array[Actor]:
	var actors: Array[Actor]
	for node: Node in get_tree().get_nodes_in_group(
		TurnManager.get_lowercase_team(team) + '_team_actors'
	):
		actors.append(node)
	return actors

## Search the Marker2D nodes of a team
func get_team_positions(team: String) -> Array[Marker2D]:
	var markers: Array[Marker2D]
	for node: Node in get_tree().get_nodes_in_group(team + '_team_positions'):
		markers.append(node as Marker2D)
	return markers

## Roll Everyone Speed Dices, except for first event
func roll_everyone_speed_dices() -> void:
	for actor: Actor in get_children():
		actor.roll_speed_dices()

## Hide Everyone Speed Dices and lights
func hide_everyone_ui_components() -> void:
	for actor: Actor in get_children():
		actor.hide_speed_dices()
		actor.hide_lights()

## Every Actor rush to their targets, due exceptions
func rush_everyone_to_targets() -> void:
	for actor: Actor in get_children():
		actor.rush_to_target()
