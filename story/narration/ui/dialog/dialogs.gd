extends Control

const Dialog = preload("res://story/narration/ui/dialog/dialog.gd")

## Current default dialog Node
var dialog: Dialog

## Finish immediately
func finish_immediately() -> void:
	if dialog:
		dialog.finish_immediately()

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

## Hide dialog
func hide_dialog(fade_out_time: float = 0.3) -> void:
	if fade_out_time > 0.0:
		dialog.fade_out(fade_out_time)
	else:
		dialog.hide()

## Clear dialog
func clear_dialog() -> void:
	dialog.clear()

## Set Title Name
func set_title_name(
	char_name: String = '', 
) -> void:
	$Normal/Box/Title/Name.text = char_name

## Set Title Affiliation
func set_title_affiliation(
	char_affiliation: String = '', 
) -> void:
	$Normal/Box/Title/Affiliation.text = char_affiliation
