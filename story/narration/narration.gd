extends Node

var locale: String = "en"

## Expressions
var expression: Expression = Expression.new()

## Narration Script
var narration_script: Array = [
	{ "action": "set_background('juline_room')" },
	{ "action": "fade_in()" },
	{ "await": "1.0" },
	{ "action": "set_default_dialog('center')" },
	{ "action": "clear_dialog()" },
	{ "action": "show_dialog()" },
	{ "await": "1.0" },
	{ "en": "La luz de la mañana se mecía suavemente en la ventana." },
	{ "en": "Allí sobre la cama yacía una joven dormida." },
	#{ "action": "set_location('...')" },
	#{ "action": "show_location()" },
]

func _ready() -> void:
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
# --- --- --- Narration Actions
# ------------------------------------
## Set Background
func set_background(image_name: String) -> void:
	$Background.texture = load("res://media/story/background/" + image_name + ".jpg")

## Fade in effect for the Narration
func fade_in() -> void:
	$UILayer/UI/Fade.show()
	$UILayer/UI/Fade.fade_out()

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

## Set title
func set_title(
	char_name: String = '', 
	char_affiliation: String = ''
) -> void:
	$UILayer/UI/Dialogs.set_title(char_name, char_affiliation)

# ------------------------------------
# --- --- --- Location Actions
# ------------------------------------
## Set location
func set_location(
	location_name: String = ''
) -> void:
	$UILayer/UI/Location.set_location(location_name)

## Show location
func show_location(fade_in_time: float = 0.3) -> void:
	$UILayer/UI/Location.show_location(fade_in_time)
