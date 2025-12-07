extends Control

## Amount added to scroll velocity when scroll event happens
const SCROLL_IMPULSE: float = 600.0

## Maximum allowed accumulated scroll velocity pointing up
const SCROLL_VELOCITY_MIN: float = -1200.0
## Maximum allowed accumulated scroll velocity pointing down
const SCROLL_VELOCITY_MAX: float = 1200.0

## Smoothing factor for interpolation
const SCROLL_SMOOTHING_EXP: float = 1.0

## Multiplier applied to the scroll velocity
const SCROLL_DAMPING_BASE: float = 1.0

## Extra damping applied depending on current scroll speed
const SCROLL_DAMPING_MULTIPLIER: float = 30.0

# Normalization factor for scroll speed (max speed)
const SCROLL_SPEED_NORMALIZER: float = 600.0

@onready var scroller: Scroller = $SmothScroll

var scroll: float = 0.0

var is_emulate_touch_on: bool

func _ready() -> void:
	is_emulate_touch_on = ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse")
	
	if OS.has_feature("mobile") or is_emulate_touch_on:
		if OS.has_feature("editor") and not OS.has_feature("mobile") and is_emulate_touch_on:
			print_rich("[color=yellow]Warning: emulate_touch is ON[/color]")
		set_process(false)
		scroller.mouse_filter = Control.MOUSE_FILTER_PASS
	else:
		gui_input.connect(_handle_scroll_events)
		scroller.mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_process(true)

func _handle_scroll_events(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if scroll < 0.0:
				scroll = 0.0
			scroll += SCROLL_IMPULSE
			set_process(true)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if scroll > 0.0:
				scroll = 0.0
			scroll -= SCROLL_IMPULSE
			set_process(true)

		scroll = clampf(scroll, SCROLL_VELOCITY_MIN, SCROLL_VELOCITY_MAX)


func _process(delta: float) -> void:
	var weight: float = 1.0 - exp(-SCROLL_SMOOTHING_EXP * delta)

	scroller.scroll_vertical += int(scroll * weight)

	var damping := SCROLL_DAMPING_BASE + SCROLL_DAMPING_MULTIPLIER * (
		1.0 - clampf(absf(scroll) / SCROLL_SPEED_NORMALIZER, 0.0, 1.0)
	)

	scroll = lerpf(scroll, 0.0, 1.0 - exp(-damping * delta))
	if is_zero_approx(scroll):
		set_process(false)
