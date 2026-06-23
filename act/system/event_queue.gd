class_name EventQueue extends RefCounted

var events: Array[Event] = []

func add(event: Event):
	events.append(event)

func remove(target_event: Event):
	for event in events:
		if event == target_event:
			events.erase(target_event)
