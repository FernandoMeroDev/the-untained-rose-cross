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

var dependencies = {}

func init(config, actor_dependencies):
	dependencies = actor_dependencies
	var actor_control: ActorControl
	var i: int
	for team in ['left', 'right']:
		i = 0
		for actor_data in config['teams'][team]:
			match team:
				'left':
					actor_control = (
						LeftActorControlScene.instantiate() as ActorControl
					)
				'right':
					actor_control = (
						RightActorControlScene.instantiate() as ActorControl
					)
			actor_control.init(actor_data)
			add_child(actor_control)
			actor_control.position = positions[team][i]
			actor_control.z_index = 5 - i
			dependencies['scenary.actors'].find(actor_data['id']).actor_control = actor_control
			i += 1

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
