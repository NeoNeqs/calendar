class_name ParseResult
extends Result


func _init(_error: Err, _reason: String, _result: Calendar) -> void:
	super._init(_error, _reason, _result)


static func ok(_result: Calendar) -> ParseResult:
	return ParseResult.new(Err.None, "", _result)


static func error(_error: Err, _reason: String) -> ParseResult:
	return ParseResult.new(_error, _reason, null)


func get_result() -> Calendar:
	return __result
 	
