extends Node2D

const ActorScene: PackedScene = preload("res://act/scenary/actors/actor.tscn")
const EmotionPoint = preload("res://act/hud/actors/actor_control/emotion_points/point.gd")

# ActorN -> Scenary/Actors events listeners
func _on_actor_died(actor: Actor) -> void:
	handle_actor_died(actor)

# ActorN -> Scenary/Actors events handlers
func handle_actor_died(dead_actor: Actor) -> void:
	for actor: Actor in get_team_actors(dead_actor.team):
		actor.emotionalize(3, EmotionPoint.Types.NEGATIVE)

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
			actor.max_emotion_level = config['max_emotion_level'][team]
			actor.position_marker2d = position_node
			actor.global_position = position_node.global_position
			actor.flip_h(team == 'right')
			actor.add_to_group('actors')
			actor.add_to_group(team + '_team_actors')
			actors.append(actor)
			i += 1
	#print('Inited Actors')
	return actors

## Checksif teams can continue the fight
func check_teams_can_continue() -> bool:
	var left_can_continue: bool = false
	var right_can_continue: bool = false
	for left_actor: Actor in get_team_actors(TurnManager.Teams.LEFT):
		if left_actor.alive:
			left_can_continue = true
			break
	for right_actor: Actor in get_team_actors(TurnManager.Teams.RIGHT):
		if right_actor.alive:
			right_can_continue = true
			break
	return left_can_continue and right_can_continue

## Repositionate Actors in theirs Markers 2D
func repositionate_everyone() -> void:
	var actors: Array[Node] = get_children()
	for actor: Actor in actors:
		actor.play_idle_animation()
		actor.global_position = actor.position_marker2d.global_position
		actor.flip_h(actor.team == TurnManager.Teams.RIGHT)

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

## Show Everyone Speed Dices and lights
func show_everyone_ui_components() -> void:
	for actor: Actor in get_children():
		actor.show_speed_dices()
		actor.show_lights()

## Restart Speed Dices
func restart_everyone_speed_dices() -> void:
	for actor: Actor in get_children():
		actor.restart_speed_dices()

## Recover Everyone Staggered
func recover_everyone_staggered() -> void:
	for actor: Actor in get_children():
		actor.recover_from_staggered()

## Every Actor rush to their targets, due exceptions
func rush_everyone_to_targets() -> void:
	for actor: Actor in get_children():
		actor.rush_to_target()

## Refill Everyone Light
func refill_everyone_light() -> void:
	for actor: Actor in get_children():
		actor.refill_light()

## Everyone Draw Cards
func everyone_draw_cards() -> void:
	for actor: Actor in get_children():
		actor.draw_cards()
		actor.cards_used_count = 0

## Actors count cards used
func everyone_count_cards_used() -> void:
	for actor: Actor in get_children():
		actor.count_cards_used()

## Everyone clear Defensive Dice Queue
func clear_everyone_defensive_dice_queue() -> void:
	for actor: Actor in get_children():
		actor.defensive_dice_queue = []

## Everyone clear their Card Resolver
func clear_everyone_card_resolver() -> void:
	for actor: Actor in get_children():
		actor.clear_card_resolver()

## Remove dead Actros
func remove_dead_actors() -> void:
	for actor: Actor in get_children():
		if not actor.alive:
			remove_child(actor)

## Hide dead Actros
func hide_dead_actors() -> void:
	for actor: Actor in get_children():
		if not actor.alive:
			actor.hide()
