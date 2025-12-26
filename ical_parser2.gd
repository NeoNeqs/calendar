class_name ICalParser2
extends Node

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
#var o_events: Dictionary[int, Array] = {}

func _read_lines(file_path: String) -> PackedStringArray:
	var file := FileAccess.open(file_path, FileAccess.READ)
	var content := PackedStringArray()

	while not file.eof_reached():
		content.append(file.get_line())
	file.close()

	return content

func parse(file_path: String) -> int:
	var content: PackedStringArray = _read_lines("user://events.ical")
	var index: int = _parse_header(content)
	
	_parse_events(content, index)
	return 0


func _parse_header(content: PackedStringArray) -> int:
	var i: int = 0
	
	var n: int = content.size()
	while i < n:
		var line: String = content[i]
		
		if line.begins_with(ICAL_VERSION):
			version = float(line.substr(ICAL_VERSION.length()))
		elif line.begins_with(ICAL_PRODID):
			title = line.substr(ICAL_PRODID.length()).replace("-//", '').replace("//", "")
		elif line.begins_with(ICAL_EVENT_BEGIN):
			break
		i += 1
	
	return i

func _parse_events(content: PackedStringArray, index: int) -> void:
	var o_events: Dictionary[int, Array] = {}
	
	var n: int = content.size()
	var i: int = index
	
	var event: Event
	while i < n:
		var line: String = content[i]
		
		if line.begins_with(ICAL_EVENT_BEGIN):
			event = Event.new()
		elif line.begins_with(ICAL_EVENT_SUMMARY):
			event.summary = line.substr(ICAL_EVENT_SUMMARY.length())
			if i + 1 < n:
				var next_line: String = content[i + 1]
				if next_line[0] == " ":
					event.summary += next_line
					i += 1
			event.summary = event.summary.replace('\\', '')
		elif line.begins_with(ICAL_EVENT_DESCRIPTION):
			event.description = line.substr(ICAL_EVENT_DESCRIPTION.length())
			if i + 1 < n:
				var next_line: String = content[i + 1]
				if next_line[0] == " ":
					event.description += next_line
					i += 1
			event.description = event.description.replace('\\', '')
		elif line.begins_with(ICAL_EVENT_LOCATION):
			event.location = line.substr(ICAL_EVENT_LOCATION.length())
			if i + 1 < n:
				var next_line: String = content[i + 1]
				if next_line[0] == " ":
					event.location += next_line
					i += 1
			event.location = sanitize(event.location)
		elif line.begins_with(ICAL_EVENT_DTSTART):
			var date: String = line.substr(ICAL_EVENT_DTSTART.length())
			event.dt_start = Date.from_ical_date_string(date)
		elif line.begins_with(ICAL_EVENT_DTEND):
			var date: String = line.substr(ICAL_EVENT_DTEND.length())
			event.dt_end = Date.from_ical_date_string(date)
		elif line.begins_with(ICAL_EVENT_DTSTAMP):
			var date: String = line.substr(ICAL_EVENT_DTSTAMP.length())
			event.dt_stamp = Date.from_ical_date_string(date)
		elif line.begins_with(ICAL_EVENT_END):
			var ts := event.dt_start.to_unix_date()
			
			if not ts in o_events:
				o_events[ts] = [event]
			else:
				o_events[ts].append(event)
		i += 1
	Config.set_events(o_events)
	Config.save_()

func sanitize(str: String) -> String:
	var result := ""
	
	var n: int = str.length()
	var i: int = 0
	while i < n:
		if str[i] == '<':
			i = str.find('>', i) + 1
			continue
		if str[i] == '\\':
			i += 1
			continue
		
		result += str[i]
		i += 1
	return result
