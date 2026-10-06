extends OptionButton

## Locales
var locales: Array = [
	"en",
	"es",
]

func _ready() -> void:
	var current_locale: String = TranslationServer.get_locale()
	var i: int = 0
	for locale in locales:
		if locale == current_locale:
			selected = i
			break
		i += 1

func _on_item_selected(index: int) -> void:
	TranslationServer.set_locale(locales[index])
	GameState.config["language"] = locales[index]
	GameState.save_config()
