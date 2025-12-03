class_name Calendar
extends RefCounted

var version: float = INF
var prodid: String = ""
var events: Array[Event] = []


class Event:
	var summary: String
	var dt_start: Date
	var dt_end: Date
	var dt_stamp: Date
	var description: String
	var location: String


class Date:
	var timezone: String
	var unix_timestamp: int
	
	static func from(date_string: String) -> Date:
		var d := Date.new()
		d.timezone = d.__get_time_zone_from_date_string(date_string)
		d.unix_timestamp = d.__get_unix_time_from_date_string(date_string)
		return d

	func _to_string() -> String:
		return "%s:%s" % [timezone, Time.get_datetime_string_from_unix_time(unix_timestamp, true)]
	
	# TZID=Europe/Warsaw;VALUE=DATE-TIME:20251001T094500
	func __get_time_zone_from_date_string(date_string: String) -> String:
		var offset := 5
		if date_string[-1] == 'Z':
			return "UTC"
		
		var semicolon_index := date_string.find(';')
		
		
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
		
		return Time.get_unix_time_from_datetime_string("".join(p))
		
