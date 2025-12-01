extends Control


func _ready() -> void:
	var a := Time.get_ticks_usec()
	var parser  := ICalParser.new()
	parser.parse()
	var b := Time.get_ticks_usec()
	print(b-a)
	print(parser.events.size())
