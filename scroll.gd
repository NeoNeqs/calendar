extends ScrollContainer
class_name Scroller

var labels: Array[Label]
@onready var fixed_label: Label = $"../FixedLabel"

var active_index := 0:
	get(): return active_index
	set(v): 
		active_index = v;
		for i: int in labels.size():
			labels[i].set_process(i == active_index or i == active_index + 1)
			
#var scroll_direction: int = 0
#var _prev_scroll_vertical: int = 0




func _ready() -> void:
	set_process(false)
	scroll_started.connect(func() -> void: set_process(true))
	scroll_ended.connect(func() -> void: set_process(false))
	var index := 0
	
	for child: Node in get_child(0).get_children():
		if child is BetterLabel:
			child.index = index
			index += 1
			labels.append(child)

	fixed_label.text = labels[0].text
	for i: int in 10:
		await  get_tree().physics_frame
	

#func _process(_delta: float) -> void:
	#scroll_direction = scroll_vertical - _prev_scroll_vertical
	#_prev_scroll_vertical = scroll_vertical
	

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
