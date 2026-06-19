extends Control

const ActorControl = preload("res://act/hud/actors/actor_control/actor_control.gd")
const LeftActorControlScene: PackedScene = preload("res://act/hud/actors/actor_control/left_actor_control.tscn")
const RightActorControlScene: PackedScene = preload("res://act/hud/actors/actor_control/right_actor_control.tscn")

## Positions for place Actor Controls in UI
const positions: Dictionary[String, Array] = {
	'left': [
		Vector2(78, 245),
		Vector2(18, 174),
		Vector2(-20, 111),
		Vector2(-20, 40),
		Vector2(-18, -36),
	],
	'right': [
		Vector2(1537, 245),
		Vector2(1608, 174),
		Vector2(1637, 111),
		Vector2(1642, 40),
		Vector2(1643, -36),
	],
}

## Index for left positions
var i_left: int = 0

## Index for right positions
var i_right: int = 0

func init(actors: Array[Actor]):
	var actor_control: ActorControl
	for actor: Actor in actors:
		var i: int = get('i_' + actor.team)
		match actor.team:
			'left':
				actor_control = (
					LeftActorControlScene.instantiate() as ActorControl
				)
			'right':
				actor_control = (
					RightActorControlScene.instantiate() as ActorControl
				)
		actor_control.init(actor)
		add_child(actor_control)
		actor_control.position = positions[actor.team][i]
		actor_control.z_index = 5 - i
		set('i_' + actor.team, i + 1)

## Search Actor Control by Actor ID
func find_actor(id) -> ActorControl:
	var result: ActorControl
	for control: ActorControl in get_children():
		if control.actor_id == id: result = control; break
	return result

func focus_actor(id):
	var actor = find_actor(id)
	actor.focus()

func unfocus_actor(id):
	var actor = find_actor(id)
	actor.unfocus()

func outline_actor(id):
	var actor: TextureRect = find_actor(id)
	actor.outline()

func unoutline_actor(id):
	var actor: TextureRect = find_actor(id)
	actor.unoutline()
