class_name EventNode
extends PanelContainer

const gray := Color("a9a9a9")

@onready var start_time: Label = $MarginContainer/HBoxContainer/Col1/StartTime
@onready var end_time: Label = $MarginContainer/HBoxContainer/Col1/EndTime
@onready var title: Label = $MarginContainer/HBoxContainer/Col2/Title
@onready var info: Label = $MarginContainer/HBoxContainer/Col2/Info
@onready var rel: Label = $MarginContainer/HBoxContainer/Col3/Rel

var _event: Event
var _is_old: bool

static var current: int

static func _static_init() -> void:
	current = Date.utc_now().unix_timestamp

func set_data(event: Event, is_old: bool) -> void:
	_event = event
	_is_old = is_old


func _process(_delta: float) -> void:
	if not _event:
		set_process(false)
		return
		
	start_time.text = _event.dt_start.to_human_time()
	end_time.text = _event.dt_end.to_human_time()
	var split := _event.summary.split('|')
	title.text = split[1].strip_edges().replace('\\', '')
	info.text = "%s\n%s\n%s" % [
		_event.description,
		split[0].strip_edges(),
		_event.location
	]
	info.text = info.text.replace('\\', '')
	
	var start_diff := _event.dt_start.unix_timestamp - current
	var end_diff := _event.dt_end.unix_timestamp - current

	if end_diff < 0:
		# Event has fully ended
		rel.text = "ENDED %s AGO" % _format_diff(end_diff)

	elif start_diff > 0:
		# Event has not started yet
		rel.text = "STARTS IN %s" % _format_diff(start_diff)

	else:
		# We are between start and end → event is currently happening
		rel.text = "ENDS IN %s" % _format_diff(end_diff)
	
	if _is_old:
		start_time.label_settings.font_color = gray
		end_time.label_settings.font_color = gray
		title.label_settings.font_color = gray
		info.label_settings.font_color = gray
		rel.label_settings.font_color = gray
	
	set_process(false)


func _format_diff(seconds: int) -> String:
	var m := int(abs(seconds) / 60) % 60
	var h := int(abs(seconds) / 3600) % 24
	var d := int(abs(seconds) / 86400)

	if d > 0:
		return "%d DAYS" % d
	elif h > 0:
		return "%d HOURS" % h
	else:
		return "%d MINUTES" % max(m, 1)  # avoid "0 minutes"
