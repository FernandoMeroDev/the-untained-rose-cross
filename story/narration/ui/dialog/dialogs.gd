extends Control

## Current default dialog Node
var dialog: Control

## Type text
func type_text(locale: String, line: Dictionary) -> void:
	await dialog.type_text(locale, line)

## Set default dialog using its Node name.
## 'normal' => $Normal
func set_default_dialog(p_dialog_node_name: String = 'normal') -> void:
	dialog = get_node(p_dialog_node_name.capitalize())

## Show Dialog
func show_dialog(fade_in_time: float = 0.3) -> void:
	if fade_in_time > 0.0:
		dialog.fade_in(fade_in_time)
	else:
		dialog.show()

## Clear dialog
func clear_dialog() -> void:
	dialog.clear()

## Set Title
func set_title(
	char_name: String = '', 
	char_affiliation: String = '',
) -> void:
	$Normal/Box/Title/Name.text = char_name
	$Normal/Box/Title/Affiliation.text = char_affiliation
