extends Control

@onready var control: Scroller = $Control

var scroll: int = 0

var t: Tween

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if event.pressed:
				scroll += 1
				set_process(true)
			
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed:
				scroll += -1
				set_process(true)
		

func _process(delta: float) -> void:
	if not scroll == 0:
		if not t or not t.is_valid():
			t = create_tween()
			t.tween_property(control, "scroll_vertical", control.scroll_vertical - 400 * scroll, 0.4)
			t.tween_callback(_reset)
		
		if t.is_running():
			t.stop()
			t.tween_property(control, "scroll_vertical", control.scroll_vertical - 400 * scroll, 0.4)
			t.play()
		set_process(false)

func _reset() -> void:
	scroll = 0
