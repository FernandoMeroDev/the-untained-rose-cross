extends Label

var active: bool = false

func init() -> void:
	$Interval.timeout.connect(change_number)
	start()

func start() -> void:
	active = true
	show()

func stop() -> void:
	active = false
	text = '1'
	hide()

func change_number():
	if active:
		var n: int = int(text)
		if n == 9: n = 0
		n += 1
		text = str(n)
