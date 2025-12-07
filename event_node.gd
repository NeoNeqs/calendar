class_name EventNode
extends PanelContainer

const gray := Color("a9a9a9")


func set_data(event: ICalParser.Event, is_old: bool) -> void:
	$MarginContainer/HBoxContainer/Col1/Label.text = "%02d:%02d" % [event.dt_start.hour, event.dt_start.minute]
	$MarginContainer/HBoxContainer/Col1/Label2.text = "%02d:%02d" % [event.dt_end.hour, event.dt_end.minute]
	var split := event.summary.split('|')
	$MarginContainer/HBoxContainer/Col2/Label.text = split[1].strip_edges()
	$MarginContainer/HBoxContainer/Col2/Label2.text = "%s\n%s\n%s" % [
		event.description,
		split[0].strip_edges(),
		event.location.replace('\\', '')
	]
	var c := Time.get_datetime_dict_from_system()
	#if event.dt_end.day == 5:
	var day_diff: int = c["day"] - event.dt_end.day
	var hour_diff: int = c["hour"] - event.dt_end.hour
	var minute_diff: int = c["minute"] - event.dt_end.minute
	if day_diff > 0:
		$MarginContainer/HBoxContainer/Col3/Label.text = "ENDED %d DAYS" % [ day_diff ]
	elif day_diff == 0 and hour_diff > 0:
		$MarginContainer/HBoxContainer/Col3/Label.text = "ENDED %d HOURS" % [ hour_diff ]
	elif day_diff == 0 and hour_diff == 0 and minute_diff > 0:
		$MarginContainer/HBoxContainer/Col3/Label.text = "ENDED %d MINUTES" % [ minute_diff ]
		
	if day_diff < 0:
		$MarginContainer/HBoxContainer/Col3/Label.text = "STARTS IN\n%d DAYS" % [ absi(day_diff) ]
	elif day_diff == 0 and hour_diff < 0:
		$MarginContainer/HBoxContainer/Col3/Label.text = "STARTS IN\n%d HOURS" % [ absi(hour_diff) ]
	elif day_diff == 0 and hour_diff == 0 and minute_diff < 0:
		$MarginContainer/HBoxContainer/Col3/Label.text = "STARTS IN\n%d MINUTES" % [ absi(minute_diff) ]
	if is_old:
		$MarginContainer/HBoxContainer/Col1/Label.label_settings.font_color = gray
		$MarginContainer/HBoxContainer/Col1/Label2.label_settings.font_color = gray
		$MarginContainer/HBoxContainer/Col2/Label.label_settings.font_color = gray
		$MarginContainer/HBoxContainer/Col2/Label2.label_settings.font_color = gray
		$MarginContainer/HBoxContainer/Col3/Label.label_settings.font_color = gray
