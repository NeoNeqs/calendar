class_name EventNode
extends PanelContainer

const gray := Color("a9a9a9")

@onready var start_time: Label = $MarginContainer/HBoxContainer/Col1/StartTime
@onready var end_time: Label = $MarginContainer/HBoxContainer/Col1/EndTime
@onready var title: Label = $MarginContainer/HBoxContainer/Col2/Title
@onready var info: Label = $MarginContainer/HBoxContainer/Col2/Info
@onready var rel: Label = $MarginContainer/HBoxContainer/Col3/Rel

var _event: ICalParser.Event
var _is_old: bool


func set_data(event: ICalParser.Event, is_old: bool) -> void:
	_event = event
	_is_old = is_old


func _process(_delta: float) -> void:
	if not _event:
		set_process(false)
		return
		
	start_time.text = "%02d:%02d" % [_event.dt_start.hour, _event.dt_start.minute]
	end_time.text = "%02d:%02d" % [_event.dt_end.hour, _event.dt_end.minute]
	var split := _event.summary.split('|')
	title.text = split[1].strip_edges()
	info.text = "%s\n%s\n%s" % [
		_event.description,
		split[0].strip_edges(),
		_event.location.replace('\\', '')
	]
	
	var current := int(Time.get_unix_time_from_system()) + 7 * 60 * 60 + 60 * 60
	var end_diff := _event.dt_end.unix_timestamp - current
	var start_diff := _event.dt_start.unix_timestamp - current
	
	var end_days := int(end_diff / 86400.0)
	var end_hours := int((end_diff % 86400) / 3600.0)
	var end_minutes := int((end_diff % 3600) / 60.0)
	
	var start_days := int(start_diff / 86400.0)
	var start_hours := int((start_diff % 86400) / 3600.0)
	var start_minutes := int((start_diff % 3600) / 60.0)
	
	if end_days < 0:
		rel.text = "ENDED %d DAYS" % [ -end_days]
	elif end_days == 0:
		if end_hours < 0:
			rel.text = "ENDED %d HOURS" % [ -end_hours ]
		elif end_hours == 0:
			if end_minutes < 0:
				rel.text = "ENDED %d MINUTES" % [ -end_minutes ]
			elif end_minutes == 0:
				rel.text = "ENDED NOW"
			else:
				rel.text = "STARTS IN %d MINUTES" % [ -start_minutes ]
		else:
			if end_hours > -2:
				rel.text = "STARTS IN %d HOURS" % [ start_hours ]
			else:
				rel.text = "STARTS IN %d MINUTES" % [ (start_hours * 60 + start_minutes) ]
	else:
		rel.text = "STARTS IN %d DAYS" % [ start_days ]
	
	
	#if day_diff > 0:
		#rel.text = "ENDED %d DAYS" % [ day_diff ]
	#elif day_diff == 0:
		#if hour_diff > 0:
			#rel.text = "ENDED %d HOURS" % [ hour_diff ]
		#elif hour_diff < 0:
			#rel.text = "ENDS IN %d MINUTES" % [absi(hour_diff) * 60 + absi(minute_diff)]
	#elif day_diff == 0 and hour_diff == 0 and minute_diff > 0:
		#rel.text = "ENDED %d MINUTES" % [ minute_diff ]
		#
	#if day_diff < 0:
		#rel.text = "STARTS IN\n%d DAYS" % [ absi(day_diff) ]
	#elif day_diff == 0 and hour_diff < 0:
		#rel.text = "STARTS IN\n%d HOURS" % [ absi(hour_diff) ]
	#elif day_diff == 0 and hour_diff == 0 and minute_diff < 0:
		#rel.text = "STARTS IN\n%d MINUTES" % [ absi(minute_diff) ]
	#
	if _is_old:
		start_time.label_settings.font_color = gray
		end_time.label_settings.font_color = gray
		title.label_settings.font_color = gray
		info.label_settings.font_color = gray
		rel.label_settings.font_color = gray
	
	set_process(false)
