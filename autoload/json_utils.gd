extends Node

func load_json(path) -> Variant:
	var file = FileAccess.open(path, FileAccess.READ)
	return JSON.parse_string(file.get_as_text())
