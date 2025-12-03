class_name EventsParseResult
extends Result


func _init(_error: Err, _reason: String, _result: Array[Calendar.Event]) -> void:
	super._init(_error, _reason, _result)


static func ok(_result: Array[Calendar.Event]) -> EventsParseResult:
	return EventsParseResult.new(Err.None, "", _result)


static func error(_error: Err, _reason: String) -> EventsParseResult:
	return EventsParseResult.new(_error, _reason, [])


func get_result() -> Array[Calendar.Event]:
	return __result
