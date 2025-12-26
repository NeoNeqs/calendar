extends RefCounted
class_name ICalParser

const ICAL_BEGIN := "BEGIN:VCALENDAR"
const ICAL_END := "END:VCALENDAR"

const ICAL_VERSION := "VERSION:"
const ICAL_PRODID := "PRODID:"

const ICAL_EVENT_BEGIN := "BEGIN:VEVENT"
const ICAL_EVENT_END := "END:VEVENT"

const ICAL_EVENT_SUMMARY := "SUMMARY:"
const ICAL_EVENT_DTSTART := "DTSTART;"
const ICAL_EVENT_DTEND := "DTEND;"
const ICAL_EVENT_DTSTAMP := "DTSTAMP;"
const ICAL_EVENT_DESCRIPTION := "DESCRIPTION:"
const ICAL_EVENT_LOCATION := "LOCATION:"
const ICAL_EVENT_TZID := "TZID="

var version: float = INF
var title: String = ""
var o_events: Dictionary[int, Array] = {}

func parse(file_path: String) -> int:
	var file := FileAccess.open(file_path, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	
	var index := _parse_header(content)
	
	if index == -1:
		print("OH no! Bad data!")
		return index
	
	index = _parse_events(content, index)
	
	if index == -1:
		print("Oh noooo! Something bad has happened....")
		return index
	return 0


func _parse_header(content: String) -> int:
	var index := 0
	
	var n: int = content.length()
	
	while index < n:
		if content.substr(index, ICAL_BEGIN.length()) == ICAL_BEGIN:
			index += ICAL_BEGIN.length()
		elif content.substr(index, ICAL_VERSION.length()) == ICAL_VERSION:
			index += ICAL_VERSION.length()
			var version_end_index := content.find(' ', index)
			if version_end_index == -1:
				return -1
			
			version = float(content.substr(index, version_end_index - index))
			index = version_end_index
		elif content.substr(index, ICAL_PRODID.length()) == ICAL_PRODID:
			index += ICAL_PRODID.length()
			
			var title_end_index: int
			if is_inf(version):
				title_end_index = content.find(ICAL_VERSION, index)
			else:
				title_end_index = content.find(ICAL_EVENT_BEGIN, index)
				if title_end_index == -1:
					title_end_index = content.find(ICAL_END, index)
			
			if title_end_index == -1:
				return -1
			
			title = content.substr(index, title_end_index - index)
			index = title_end_index
		else: 
			index += 1
		
		if not is_inf(version) and not title.is_empty():
			break
			
	return index

func _parse_events(content: String, index: int) -> int:
	var event: Event
	
	var n: int = content.length()
	
	while index < n:
		if content.substr(index, ICAL_EVENT_BEGIN.length()) == ICAL_EVENT_BEGIN:
			event = Event.new()
			index += ICAL_EVENT_BEGIN.length() + 1
		
		elif content.substr(index, ICAL_EVENT_SUMMARY.length()) == ICAL_EVENT_SUMMARY:
			index += ICAL_EVENT_SUMMARY.length()
			var summary_end_index := content.find(ICAL_EVENT_DTSTART, index)
			if summary_end_index == -1:
				return -1
			
			event.summary = content.substr(index, summary_end_index - index)
			index = summary_end_index
		elif content.substr(index, ICAL_EVENT_DTSTART.length()) == ICAL_EVENT_DTSTART:
			index += ICAL_EVENT_DTSTART.length()
			var dtstart_end_index := content.find(' ', index)
			if dtstart_end_index == -1:
				return -1
			
			var date: String = content.substr(index, dtstart_end_index - index)
			event.dt_start = Date.from_ical_date_string(date)
			index = dtstart_end_index
		elif content.substr(index, ICAL_EVENT_DTEND.length()) == ICAL_EVENT_DTEND:
			index += ICAL_EVENT_DTEND.length()
			var dtend_end_index := content.find(' ', index)
			if dtend_end_index == -1:
				return -1
			var date: String = content.substr(index, dtend_end_index - index)
			
			event.dt_end = Date.from_ical_date_string(date)
			index = dtend_end_index
		elif content.substr(index, ICAL_EVENT_DTSTAMP.length()) == ICAL_EVENT_DTSTAMP:
			index += ICAL_EVENT_DTSTAMP.length()
			var dtstamp_end_index := content.find(' ', index)
			if dtstamp_end_index == -1:
				return -1
			
			var date: String = content.substr(index, dtstamp_end_index - index)
			event.dt_stamp = Date.from_ical_date_string(date)
			index = dtstamp_end_index
		elif content.substr(index, ICAL_EVENT_DESCRIPTION.length()) == ICAL_EVENT_DESCRIPTION:
			index += ICAL_EVENT_DESCRIPTION.length()
			var description_end_index := content.find(ICAL_EVENT_LOCATION, index)
			if description_end_index == -1:
				return -1
			
			event.description = content.substr(index, description_end_index - index)
			index = description_end_index
		elif content.substr(index, ICAL_EVENT_LOCATION.length()) == ICAL_EVENT_LOCATION:
			index += ICAL_EVENT_LOCATION.length()
			var location_end_index := content.find(ICAL_EVENT_END, index)
			if location_end_index == -1:
				return -1
			
			event.location = content.substr(index, location_end_index - index)
			index = location_end_index
		elif content.substr(index, ICAL_EVENT_END.length()) == ICAL_EVENT_END:
			index += ICAL_EVENT_END.length() + 1
			var ts := event.dt_start.to_unix_date()
			
			if not ts in o_events:
				o_events[ts] = [event]
			else:
				o_events[ts].append(event)
				
		else:
			index += 1
		
	return index

#class Event:
	#var summary: String
	#var dt_start: Date
	#var dt_end: Date
	#var dt_stamp: Date
	#var description: String
	#var location: String
