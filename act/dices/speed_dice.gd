extends TextureButton

var value = null

enum States { UNDETERMINED, DETERMINED }

var status = States.UNDETERMINED

var animation_shake: Tween

func init(speed):
	status = States.UNDETERMINED
	$Number.text = str(speed['min']) + '~' + str(speed['max'])
	$Random/Interval.timeout.connect(change_random_number)
	init_animate_shake()

func change_random_number():
	if status == States.UNDETERMINED:
		var n = int($Random.text)
		if n == 9: n = 0
		n += 1
		$Random.text = str(n)

func init_animate_shake(duration = 1.8, strength = 2.0):
	var original_pos = self.position
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	var steps = 6
	for i in steps:
		var offset = Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		tween.tween_property(self, "position", original_pos + offset, duration / steps)
	tween.tween_property(self, "position", original_pos, duration / steps)
	tween.set_loops()
	animation_shake = tween

func set_speed(n):
	value = n
	animation_shake.kill()
	status = States.DETERMINED
	$Number.text = str(value)
