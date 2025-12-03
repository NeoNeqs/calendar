class_name ICalParser2
extends RefCounted

const ICAL_BEGIN: String = "BEGIN:VCALENDAR"
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

var _index: int = 0


func parse(file_path: String) -> ParseResult:
	var result: FileContentResult = read_all_text(file_path)
	if result.is_error():
		return ParseResult.error(result.get_error(), result.get_reason())
	
	# Yes, I'm twisted up inside like that :)
	var contents_ref: Array[String] = [result.get_result()]
	return _parse(contents_ref)
	

func read_all_text(file_path: String) -> FileContentResult:
	var contents: String = FileAccess.get_file_as_string(file_path)
	var open_error: Error = FileAccess.get_open_error()
	
	if not open_error == Error.OK:
		return FileContentResult.error(
			Result.Err.InputFileReadError, 
			"Could not read file '%s'. Error code: %s" % [file_path, error_string(open_error)]
		)
	
	return FileContentResult.ok(contents)


func _parse(contents_ref: Array[String]) -> ParseResult:
	var header_parse_result := _parse_header(contents_ref)
	
	if header_parse_result.is_error():
		return header_parse_result
	
	var calendar := header_parse_result.get_result()
	var events_result := _parse_events(contents_ref)
	if events_result.is_error():
		return ParseResult.error(events_result.get_error(), events_result.get_reason())
	calendar.events = events_result.get_result()
	
	return ParseResult.ok(calendar)
	
	

func _parse_header(contents_ref: Array[String]) -> ParseResult:
	var calendar := Calendar.new()
	
	while _index < contents_ref[0].length():
		if begins_at(contents_ref, _index, ICAL_BEGIN):
			_index += ICAL_BEGIN.length() + 1
		elif begins_at(contents_ref, _index, ICAL_VERSION):
			if not is_inf(calendar.version):
				return ParseResult.error(Result.Err.InvalidData, "Found '%s' twice." % [ICAL_VERSION])
			
			_index += ICAL_VERSION.length()
			var version_end_index: int = contents_ref[0].find(' ', _index)
			if version_end_index == -1:
				return ParseResult.error(Result.Err.InvalidData, "Could not find where a '%s' ends" % [ICAL_VERSION])
				
			calendar.version = float(contents_ref[0].substr(_index, version_end_index - _index))
			_index = version_end_index
			
		elif begins_at(contents_ref, _index, ICAL_PRODID):
			if not calendar.prodid.is_empty():
				return ParseResult.error(Result.Err.InvalidData, "Found '%s' twice." % [ICAL_PRODID])
			
			_index += ICAL_PRODID.length()
			var title_end_index: int = contents_ref[0].find(ICAL_EVENT_BEGIN, _index)
			if title_end_index == -1:
				return ParseResult.error(Result.Err.InvalidData, "Could not find where a '%s' ends" % [ICAL_EVENT_BEGIN])
			
			calendar.prodid = contents_ref[0].substr(_index, title_end_index - _index)
			_index = title_end_index
		elif begins_at(contents_ref, _index, ICAL_EVENT_BEGIN):
			break
		else: 
			_index += 1
	return ParseResult.ok(calendar)

func _parse_events(contents_ref: Array[String]) -> EventsParseResult:
	var events: Array[Calendar.Event] = []
	var event: Calendar.Event
	
	while _index < contents_ref[0].length():
		if begins_at(contents_ref, _index, ICAL_EVENT_BEGIN):
			event = Calendar.Event.new()
			_index += ICAL_EVENT_BEGIN.length() + 1
		
		if begins_at(contents_ref, _index, ICAL_EVENT_SUMMARY):
			_index += ICAL_EVENT_SUMMARY.length()
			var summary_end_index := contents_ref[0].find(ICAL_EVENT_DTSTART, _index)
			if summary_end_index == -1:
				return EventsParseResult.error(Result.Err.InvalidData, "Could not find where '%s' ends." % [ICAL_EVENT_SUMMARY])
			
			event.summary = contents_ref[0].substr(_index, summary_end_index - _index)
			_index = summary_end_index
			
		elif begins_at(contents_ref, _index, ICAL_EVENT_DTSTART):
			_index += ICAL_EVENT_DTSTART.length()
			var dtstart_end_index := contents_ref[0].find(' ', _index)
			if dtstart_end_index == -1:
				return EventsParseResult.error(Result.Err.InvalidData, "Could not find where '%s' ends." % [ICAL_EVENT_DTSTART])
			
			event.dt_start = Calendar.Date.from(contents_ref[0].substr(_index, dtstart_end_index - _index))
			_index = dtstart_end_index
		elif begins_at(contents_ref, _index, ICAL_EVENT_DTEND):
			_index += ICAL_EVENT_DTEND.length()
			var dtend_end_index := contents_ref[0].find(' ', _index)
			if dtend_end_index == -1:
				return EventsParseResult.error(Result.Err.InvalidData, "Could not find where '%s' ends." % [ICAL_EVENT_DTEND])
			
			event.dt_end = Calendar.Date.from(contents_ref[0].substr(_index, dtend_end_index - _index))
			_index = dtend_end_index
		elif begins_at(contents_ref, _index, ICAL_EVENT_DTSTAMP):
			_index += ICAL_EVENT_DTSTAMP.length()
			var dtstamp_end_index := contents_ref[0].find(' ', _index)
			if dtstamp_end_index == -1:
				return EventsParseResult.error(Result.Err.InvalidData, "Could not find where '%s' ends." % [ICAL_EVENT_DTEND])
			
			#event.dt_stamp = content.substr(index, dtstamp_end_index - index)
			event.dt_stamp = Calendar.Date.from(contents_ref[0].substr(_index, dtstamp_end_index - _index))
			_index = dtstamp_end_index
		elif begins_at(contents_ref, _index, ICAL_EVENT_DESCRIPTION):
			_index += ICAL_EVENT_DESCRIPTION.length()
			var description_end_index := contents_ref[0].find(ICAL_EVENT_LOCATION, _index)
			if description_end_index == -1:
				return EventsParseResult.error(Result.Err.InvalidData, "Could not find where '%s' ends." % [ICAL_EVENT_DESCRIPTION])
			
			event.description = contents_ref[0].substr(_index, description_end_index - _index)
			_index = description_end_index
		elif begins_at(contents_ref, _index, ICAL_EVENT_LOCATION):
			_index += ICAL_EVENT_LOCATION.length()
			var location_end_index := contents_ref[0].find(ICAL_EVENT_END, _index)
			if location_end_index == -1:
				return EventsParseResult.error(Result.Err.InvalidData, "Could not find where '%s' ends." % [ICAL_EVENT_LOCATION])
			
			event.location = contents_ref[0].substr(_index, location_end_index - _index)
			_index = location_end_index
		elif begins_at(contents_ref, _index, ICAL_EVENT_END):
			_index += ICAL_EVENT_END.length() + 1
			events.append(event)
		else:
			_index += 1
		
	return EventsParseResult.ok(events)

func begins_at(source_ref: Array[String], at: int, what: String) -> bool:
	var index: int = 0
	
	while index < what.length():
		if not source_ref[0][at + index] == what[index]:
			return false
		index += 1
	
	return true
