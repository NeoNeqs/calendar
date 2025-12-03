class_name Result
extends RefCounted

enum Err {
	None,
	InputFileReadError,
	InvalidData,
}

var __error: Err = Err.None
var __reason: String
var __result: Variant

func _init(_error: Err, _reason: String, _result: Variant) -> void:
	self.__error = _error
	self.__reason = _reason
	self.__result = _result

func is_ok() -> bool:
	return __error == Err.None


func is_error() -> bool:
	return not __error == Err.None


func get_reason() -> String:
	return __reason


func get_result() -> Variant:
	return __result


func get_error() -> Err:
	return __error
