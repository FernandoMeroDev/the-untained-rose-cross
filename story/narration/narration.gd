extends Node

## Narration is finished
signal finished

## Return to start requested
signal return_to_start_requested

## Locale Language
var locale: String

## Expressions
var expression: Expression = Expression.new()

## Narration Chapter
var narration_chapter: String

## Narration Script
var narration_script: Array

## Narration Locations
var locations: Dictionary

## Narration dialog Titles
var character_titles: Dictionary

## UI event Handler
func _on_ui_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			$UILayer/UI/Dialogs.finish_immediately()
			$Characters.everyone_finish_immediately()
			$Music/VoiceLine.finish_immediately()

## Open Menu Request observers
func _on_open_pause_menu_requested() -> void:
	$UILayer/PauseMenu.show()

## Close Menu Request observers
func _on_exit_pause_menu_requested() -> void:
	$UILayer/PauseMenu.hide()

## Return to start via Pause Menu
func _on_return_to_start_requested() -> void:
	return_to_start_requested.emit()

## Skip Narration
func _on_skip_narration_pressed() -> void:
	$UILayer/UI/IDontRead.tease()
	await $UILayer/UI/IDontRead.teasing_finihed
	finished.emit()

func init(p_narration_chapter: String, narration_data: Dictionary) -> void:
	locale = GameState.config["language"]
	narration_chapter = p_narration_chapter
	narration_script = narration_data["narration_script"] 
	init_locations(narration_data["locations"])
	init_character_titles(narration_data["character_titles"])
	# Connect Signals
	$UILayer/UI.open_pause_menu_requested.connect(
		_on_open_pause_menu_requested
	)
	$UILayer/PauseMenu.exit_pause_requested.connect(
		_on_exit_pause_menu_requested
	)
	$Music/VoiceLine.narration_chapter = narration_chapter
	# Text Boxes => VoiceLine Events
	$UILayer/UI/Dialogs/Normal/Box/Text.voice_line_requested.connect(
		$Music/VoiceLine._on_voice_line_requested
	)
	$UILayer/UI/Dialogs/Center/Box/Text.voice_line_requested.connect(
		$Music/VoiceLine._on_voice_line_requested
	)
	# Skip Narration Listeners
	$UILayer/UI/Skip/Confirmation/Buttons/Confirm.pressed.connect(
		_on_skip_narration_pressed
	)
	# Execute Narration script
	await execute_narration_script()
	finished.emit()

func init_locations(narration_locations: Dictionary) -> void:
	locations = JsonUtils.load_json(
		"res://database/story/global_locations.json"
	)
	locations.merge(narration_locations, true)

func init_character_titles(narration_char_titles: Dictionary) -> void:
	character_titles = JsonUtils.load_json(
		"res://database/story/global_character_titles.json"
	)
	character_titles.merge(narration_char_titles, true)

## Execute Narration Script
func execute_narration_script() -> void:
	for line: Dictionary in narration_script:
		if line.keys().has('action'):
			execute_action(line)
		elif line.keys().has('await'):
			await timeout(float(line['await']))
		elif line.keys().has(locale):
			await type_text(line)

## Execute Action
func execute_action(line: Dictionary) -> void:
	var command: String = line['action']
	var error: Error = expression.parse(command)
	if error != OK:
		push_error(expression.get_error_text())
	expression.execute([], self)

## Type text
func type_text(line: Dictionary) -> void:
	await $UILayer/UI/Dialogs.type_text(locale, line)

## Timeout for await
func timeout(time: float = 1.0) -> Signal:
	return get_tree().create_timer(time).timeout

# ------------------------------------
# --- --- --- Characters Actions
# ------------------------------------
## Add Character
func add_character(id: String, code: String) -> void:
	$Characters.add_character(id, code)

## Show Character
func show_char(id: String, fade_in_time: float = 0.1) -> void:
	$Characters.show_char(id, fade_in_time)

## Activate Character
func activate_char(id: String) -> void:
	$Characters.activate_char(id)

## Deactivate Character
func deactivate_char(id: String) -> void:
	$Characters.deactivate_char(id)

## Change Character Animation
func change_char_animation(id: String, animation_name: String) -> void:
	$Characters.change_char_animation(id, animation_name)

## Change Character Expression
func change_char_expression(id: String, expression_name: String) -> void:
	$Characters.change_char_expression(id, expression_name)

## Play Char VFX
func play_char_vfx(id: String, vfx_name: String) -> void:
	$Characters.play_char_vfx(id, vfx_name)

## Positionate Character
func positionate_char(id: String, position: Array) -> void:
	$Characters.positionate_char(id, position)

## Simple Positionate Character
func simple_positionate_char(id: String, position: String) -> void:
	$Characters.simple_positionate_char(id, position)

## Flip Horizontally Character
func flip_h_char(id: String, flip: bool = true) -> void:
	$Characters.flip_h_char(id, flip)

# ------------------------------------
# --- --- --- Narration Actions
# ------------------------------------
## Set Background
func set_background(image_name: String) -> void:
	$Background.texture = load("res://media/story/background/" + image_name + ".jpg")

## Fade in effect for the Narration
func fade_in() -> void:
	$UILayer/UI/Fade.show()
	$UILayer/UI/Fade.fade_out()

## Play SFX
func play_sfx(sfx_name: String) -> void:
	$Music/SFX.play_sfx(sfx_name)

# ------------------------------------
# --- --- --- Dialogs Actions
# ------------------------------------
## Set default dialog using its Node name.
## 'normal' => $Normal, 'center' => $Center
func set_default_dialog(p_dialog_node_name: String = 'normal') -> void:
	$UILayer/UI/Dialogs.set_default_dialog(p_dialog_node_name)

## Clear dialog
func clear_dialog() -> void:
	$UILayer/UI/Dialogs.clear_dialog()

## Show dialog
func show_dialog(fade_in_time: float = 0.3) -> void:
	$UILayer/UI/Dialogs.show_dialog(fade_in_time)

## Hide dialog
func hide_dialog(fade_out_time: float = 0.3) -> void:
	$UILayer/UI/Dialogs.hide_dialog(fade_out_time)

## Set title
func set_title(
	char_name: String = '', 
	char_affiliation: String = ''
) -> void:
	set_title_name(char_name)
	set_title_affiliation(char_affiliation)

## Set title name
func set_title_name(
	char_name: String = '', 
) -> void:
	$UILayer/UI/Dialogs.set_title_name(char_name)

## Set title Affiliation
func set_title_affiliation(
	char_affiliation: String = ''
) -> void:
	$UILayer/UI/Dialogs.set_title_affiliation(char_affiliation)

## Set translated title
func set_title_tr(title_key: String) -> void:
	set_title(
		character_titles[title_key][locale]["name"],
		character_titles[title_key][locale]["affiliation"]
	)

## Set translated title's name
func set_title_name_tr(title_key: String) -> void:
	set_title_name(character_titles[title_key][locale]["name"])

## Set translated title's affiliation
func set_title_affiliation_tr(title_key: String) -> void:
	set_title_affiliation(character_titles[title_key][locale]["affiliation"])

# ------------------------------------
# --- --- --- Location Actions
# ------------------------------------
## Set location
func set_location(
	location_name: String = ''
) -> void:
	$UILayer/UI/Location.set_location(location_name)

## Set translated location
func set_location_tr(location_key: String) -> void:
	set_location(locations[location_key][locale])

## Show location
func show_location(fade_in_time: float = 0.3) -> void:
	$UILayer/UI/Location.show_location(fade_in_time)
