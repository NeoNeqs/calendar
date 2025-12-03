class_name FileContentResult
extends Result 


func _init(_error: Err, _reason: String, _result: String) -> void:
	super._init(_error, _reason, _result)


static func ok(_result: String) -> FileContentResult:
	return FileContentResult.new(Err.None, "", _result)


static func error(_error: Err, _reason: String) -> FileContentResult:
	return FileContentResult.new(_error, _reason, "")


func get_result() -> String:
	return __result
