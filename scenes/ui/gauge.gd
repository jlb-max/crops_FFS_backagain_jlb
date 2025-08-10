extends HBoxContainer
@onready var _bar  : TextureProgressBar = $Bar


func set_value(v: float):               # v = 0 – 100
	_bar.value = v

func set_ratio(r: float):
	_bar.value = r * _bar.max_value
	if _bar.value / _bar.max_value < 0.3:
		_bar.modulate.a = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 200.0)
	else:
		_bar.modulate.a = 1.0
