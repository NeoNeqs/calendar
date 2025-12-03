extends Control


func _ready() -> void:
	var a := Time.get_ticks_usec()
	var parser  := ICalParser.new()
	var result := parser.parse()
	#var parser  := ICalParser2.new()
	#var result := parser.parse("res://ical.txt")
	#if result.is_error():
		#print(result.get_error())
		#return
	#var calendar := result.get_result()
	var b := Time.get_ticks_usec()
	print(b-a)
	#print(parser.events.size())
	#print(parser.events[10].description)
