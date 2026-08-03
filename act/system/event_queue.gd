class_name EventQueue extends RefCounted

## Events
var events: Array[Event] = []

## Add event
func add(event: Event):
	events.append(event)

## Remove event
func remove(target_event: Event):
	for event in events:
		if event == target_event:
			events.erase(target_event)

## Remove all events
func remove_all() -> void:
	for event in events:
		events.erase(event)

## Get Event Queue size
func size() -> int:
	return events.size()

## Sort events by theirs Speed
func order_by_speed() -> void:
	events.sort_custom(
		func(event_a: Event, event_b: Event):
			if event_a.higher_speed > event_b.higher_speed:
				return true
			return false
	)

## Log in console
func log_in_console() -> void:
	print(
		"/* --- --- EVENTS DEBUG --- --- */"
	)
	print("Total Events: " + str(events.size()))
	var i: int = 1
	for event: Event in events:
		if event is Interception:
			print("/* --- " + str(i) + ". INTERCEPTION")
			print("Higher Speed: " + str(event.higher_speed))
			print(
				"Interceptor: "
				+ event.interceptor_speed_dice.parent_actor.actor_name
				+ "; Dice: "
				+ str(event.interceptor_speed_dice.id)
				+ ";"
			)
			print(
				"Target: "
				+ event.target_speed_dice.parent_actor.actor_name
				+ "; Dice: "
				+ str(event.target_speed_dice.id)
				+ ";"
			)
			print(
				"Target's Intended: "
				+ event.target_speed_dice.enemy_dice_intended.parent_actor.actor_name
				+ "; Dice: "
				+ str(event.target_speed_dice.enemy_dice_intended.id)
				+ ";"
			)
		elif event is Clash:
			print("/* --- " + str(i) + ". CLASH")
			print("Higher Speed: " + str(event.higher_speed))
			print(
				"Actor A: "
				+ event.speed_dice_a.parent_actor.actor_name
				+ "; Dice: "
				+ str(event.speed_dice_a.id)
				+ ";"
			)
			print(
				"Actor B: "
				+ event.speed_dice_b.parent_actor.actor_name
				+ "; Dice: "
				+ str(event.speed_dice_b.id)
				+ ";"
			)
		elif event is OnesideAttack:
			print("/* --- " + str(i) + ". ONESIDE")
			print("Higher Speed: " + str(event.higher_speed))
			print(
				"Attacker: "
				+ event.attacker_speed_dice.parent_actor.actor_name
				+ "; Dice: "
				+ str(event.attacker_speed_dice.id)
				+ ";"
			)
			print(
				"Target: "
				+ event.target_speed_dice.parent_actor.actor_name
				+ "; Dice: "
				+ str(event.target_speed_dice.id)
				+ ";"
			)
		i += 1
	print("/* --- --- ENDS EVENTS DEBUG --- --- */")
