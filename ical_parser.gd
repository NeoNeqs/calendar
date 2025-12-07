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
var events: Array[Event] = []

func parse() -> int:
	var file := FileAccess.open("ical.txt", FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	
	var index := _parse_header(content)
	
	if index == -1:
		print("OH no! Bad data!")
		return index
	
	_parse_events(content, index)
	
	return 0;


func _parse_header(content: String) -> int:
	var index := 0
	
	while index < content.length():
		if content.substr(index, ICAL_BEGIN.length()) == ICAL_BEGIN:
			index += ICAL_BEGIN.length()
		elif content.substr(index, ICAL_VERSION.length()) == ICAL_VERSION:
			index += ICAL_VERSION.length()
			var version_end_index := content.find(' ', index)
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
	while index < content.length():
		if content.substr(index, ICAL_EVENT_BEGIN.length()) == ICAL_EVENT_BEGIN:
			event = Event.new()
			index += ICAL_EVENT_BEGIN.length() + 1
		
		if content.substr(index, ICAL_EVENT_SUMMARY.length()) == ICAL_EVENT_SUMMARY:
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
			
			event.dt_start = Date.from(content.substr(index, dtstart_end_index - index))
			#event.dt_start = content.substr(index, dtstart_end_index - index)
			
			index = dtstart_end_index
		elif content.substr(index, ICAL_EVENT_DTEND.length()) == ICAL_EVENT_DTEND:
			index += ICAL_EVENT_DTEND.length()
			var dtend_end_index := content.find(' ', index)
			if dtend_end_index == -1:
				return -1
			
			#event.dt_end = content.substr(index, dtend_end_index - index)
			event.dt_end = Date.from(content.substr(index, dtend_end_index - index))
			index = dtend_end_index
		elif content.substr(index, ICAL_EVENT_DTSTAMP.length()) == ICAL_EVENT_DTSTAMP:
			index += ICAL_EVENT_DTSTAMP.length()
			var dtstamp_end_index := content.find(' ', index)
			if dtstamp_end_index == -1:
				return -1
			
			#event.dt_stamp = content.substr(index, dtstamp_end_index - index)
			event.dt_stamp = Date.from(content.substr(index, dtstamp_end_index - index))
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
			events.append(event)
		else:
			index += 1
		
	return index

class Event:
	var summary: String
	var dt_start: Date
	var dt_end: Date
	var dt_stamp: Date
	var description: String
	var location: String

class Date:
	const M := [
		"Jan", "Feb", "Mar", 
		"Apr", "May", "Jun", 
		"Jul", "Aug", "Sep", 
		"Oct", "Nov", "Dec"
	]
	
	const W := [
		"Mon", "Tue", "Wed", 
		"Thu", "Fri", "Sat", "Sun"
	]
	
	var timezone: String
	var unix_timestamp: int
	var year: int 
	var month: int 
	var day: int 
	var weekday: int 
	var hour: int 
	var minute: int 
	var second: int 

	static func from(date_string: String) -> Date:
		var d := Date.new()
		d.timezone = d.__get_time_zone_from_date_string(date_string)
		d.unix_timestamp = d.__get_unix_time_from_date_string(date_string)
		return d
	
	func weekname() -> String:
		return W[weekday - 1]

	func monthname() -> String:
		return M[month - 1]
	
	# TZID=Europe/Warsaw;VALUE=DATE-TIME:20251001T094500
	func __get_time_zone_from_date_string(date_string: String) -> String:
		var offset := ICAL_EVENT_TZID.length()
		if date_string[-1] == 'Z':
			return "UTC"
		
		var semicolon_index := date_string.find(';', ICAL_EVENT_TZID.length())
		
		return date_string.substr(offset, semicolon_index - offset)
	
	# TZID=Europe/Warsaw;VALUE=DATE-TIME:20251001T094500
	func __get_unix_time_from_date_string(date_string: String) -> int:
		var offset := date_string.rfind(':', date_string.length() - 15) + 1
		var p := PackedStringArray()
		p.resize(19)
		p[0] = date_string[offset + 0]
		p[1] = date_string[offset + 1]
		p[2] = date_string[offset + 2]
		p[3] = date_string[offset + 3]
		p[4] = '-'
		p[5] = date_string[offset + 4]
		p[6] = date_string[offset + 5]
		p[7] = '-'
		p[8] = date_string[offset + 6]
		p[9] = date_string[offset + 7]
		p[10] = date_string[offset + 8]
		p[11] = date_string[offset + 9]
		p[12] = date_string[offset + 10]
		p[13] = ':'
		p[14] = date_string[offset + 11]
		p[15] = date_string[offset + 12]
		p[16] = ':'
		p[17] = date_string[offset + 13]
		p[18] = date_string[offset + 14]
		
		var unix := Time.get_unix_time_from_datetime_string("".join(p))
		var datetime := Time.get_datetime_dict_from_unix_time(unix)
		
		year = datetime["year"]
		month = datetime["month"]
		day = datetime["day"]
		weekday = datetime["weekday"]
		hour = datetime["hour"]
		minute = datetime["minute"]
		second = datetime["second"]
		
		return unix
		
