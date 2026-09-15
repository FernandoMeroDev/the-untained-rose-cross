extends RichTextLabel

## Emitted when finish type current subtitle
signal typing_finished

enum States { IDLE, WAITING_TIME, TYPING }

## Subtitles status
var status: States = States.IDLE

## Movie reference
var movie: VideoStreamPlayer

## Default subtitles speed
var default_speed: float

var subtitles = [
	{
		"show_at": 2.5,
		"content": "Bendecida con ojos color lapislázuli y una encantadora, delicada apariencia, la Primera Princesa Lucine-",
	},
	{
		"show_at": 10.0,
		"content": "su cabello plateado parece mezclarse en la oscuridad, y sus labios de muñeca tienen un tono rojo como el de una rosa.",
	},
	{
		"show_at": 18.8,
		"content": "Las personas fueron cautivadas por aquella princesa, y propuestas de matrimonio de otras naciones nunca cesaron.",
	},
	{
		"show_at": 27.5,
		"content": "Su hermana gemela Juline fue también encantadoramente hermosa, un reflejo perfecto en apariencia, y bendecida con una hermosa voz cantante, obtuvo el amor de los ciudadanos.",
	},
	{
		"show_at": 39.8,
		"content": "Se decía que siempre que ellas dos existieran, la nación florecería hermosamente, y muchos llegarían a referirse a Rufenburg como la Ciudad de la Música.",
	},
	{
		"show_at": 53.5,
		"content": "Esta es la historia de estas dos hermanas y la tierra de Rufenburg.",
	},
	{
		"show_at": 61.3,
		"content": "",
	},
]

var current_subtitle

func init(p_default_speed: float = 20) -> void:
	default_speed = p_default_speed
	movie.play()
	for subtitle in subtitles:
		current_subtitle = subtitle
		status = States.WAITING_TIME
		await typing_finished
	status = States.IDLE

func _process(_delta: float) -> void:
	if status == States.WAITING_TIME:
		if movie.stream_position >= current_subtitle["show_at"]:
			show_text(
				current_subtitle["content"],
				current_subtitle["speed"] if(
					current_subtitle.keys().has("speed")
				) else default_speed
			)
			status = States.TYPING

## Show text
func show_text(content: String, typing_speed: float) -> void:
	text = content
	visible_characters = 0
	var duration: float = text.length() / typing_speed

	var tween: Tween = create_tween()
	tween.tween_property(
		self,
		"visible_characters",
		text.length(),
		duration
	)
	tween.finished.connect(
		func(): typing_finished.emit()
	)
