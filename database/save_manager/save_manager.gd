extends RefCounted

## Save Game State
func save_game(game_state: Dictionary) -> void:
	store_file("save.json", game_state)

## Load Game State
func load_game() -> Dictionary:
	return read_file("save.json")

## Save Config State
func save_config(config_state: Dictionary) -> void:
	store_file("config.json", config_state)

## Load Config State
func load_config() -> Dictionary:
	return read_file("config.json")

## Save File in user storage
func store_file(path: String, content: Variant) -> void:
	var file: FileAccess = FileAccess.open(
		"user://" + path, FileAccess.WRITE
	)
	file.store_string(JSON.stringify(content))
	file.close()

## Read File in user storage
func read_file(path: String) -> Variant:
	var file: FileAccess = FileAccess.open(
		"user://" + path, FileAccess.READ
	)
	var content: String = file.get_as_text()
	file.close()
	return JSON.parse_string(content)
