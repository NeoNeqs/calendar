extends ScrollContainer
class_name Scroller

#@onready var fixed_label: Label = $"../FixedLabel"

static var labels: Array[Label]

var active_index := 0:
	get(): return active_index
	set(v): 
		active_index = v;
		for i: int in labels.size():
			labels[i].set_process(i == active_index or i == active_index + 1)

#func _ready() -> void:
	##var index := 0
	#
	#labels.clear()
	#for child: Node in get_child(0).get_children():
		#if child is BetterLabel:
			##child.index = index
			##index += 1
			#labels.append(child)
#
	#fixed_label.text = labels[0].text

#func _ready() -> void:
	#var a := Time.get_ticks_usec()
	##var parser  := ICalParser.new()
	##var result := parser.parse()
	#var parser  := ICalParser2.new()
	#var result := parser.parse("res://ical.txt")
	#if result.is_error():
		#print(result.get_error())
		#return
	#var calendar := result.get_result()
	#var b := Time.get_ticks_usec()
	#print(b-a)
	##print(parser.events.size())
	##print(parser.events[10].description)
